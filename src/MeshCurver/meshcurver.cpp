
#include "meshcurver.hpp"

using namespace godot;

void MeshCurver::_register_methods() 
{
	godot::register_property("enableUpVector", &MeshCurver::setEnableUpVector, &MeshCurver::getEnableUpVector, true);
	godot::register_property("meshRepetitonsNumber", &MeshCurver::setMeshRepetitions, &MeshCurver::getMeshRepetitions, 1);
	godot::register_property("curvedMeshStartingOffset", &MeshCurver::setMeshOffset, &MeshCurver::getMeshOffset, 0.0f);
	godot::register_property("createTrimeshStaticBody", &MeshCurver::generateBoundingBox, &MeshCurver::getNothing, false);
	godot::register_property("xyzScale", &MeshCurver::setXYZScale, &MeshCurver::getXYZSCale, Vector3(1,1,1));

	godot::Ref<godot::ArrayMesh> defaultMesh;
	defaultMesh.instance();
	godot::register_property<MeshCurver, godot::Ref<godot::ArrayMesh>>("mainMesh", &MeshCurver::updateMesh, &MeshCurver::getMainMesh, defaultMesh);

	godot::register_method("_init", &MeshCurver::_init);
	godot::register_method("_process", &MeshCurver::_process);
	godot::register_method("updateCurve", &MeshCurver::updateCurve);
}

void MeshCurver::_process(float delta)
{
	deltaSum += delta;
	
	if (deltaSum >= updateFrequency)
	{
		deltaSum = 0.0f;
		if (updateLowerBound != -1 && get_curve()->get_point_count() != 0)
		{
			std::cout << updateLowerBound;

			curveMainMesh(get_curve(), curvedMeshStartingOffset, updateLowerBound);
			updateLowerBound = -1;
		}

	}

}

void MeshCurver::_init()
{
	mainMesh.instance();

	mainMeshMdt.instance();
	beforeCurveMdt.instance();
	curvedMeshMdt.instance();

	prevCurve.instance();
	prevCurve = get_curve()->duplicate();

	targetSt.instance();

	godot::Ref<godot::Script> test;

	if (!has_node("curvedMesh"))
	{  
		curvedMesh = godot::MeshInstance::_new();
		curvedMesh->set_name(String("curvedMesh"));
		this->add_child(curvedMesh);
	}

	this->connect(String("curve_changed"), this, String("updateCurve"));
}

void MeshCurver::updateMesh(godot::Ref<godot::ArrayMesh> newMesh)
{
	if (newMesh.is_valid() && newMesh.is_null() == false)
	{
		if (newMesh->surface_get_arrays(0).size())
		{
			//We convert the mesh input from any mesh type to an ArrayMesh
			mainMesh.instance();
			mainMesh->add_surface_from_arrays(godot::Mesh::PRIMITIVE_TRIANGLES, newMesh->surface_get_arrays(0));

			//We then create a MeshDataTool, which we will use to get the vertices
			mainMeshMdt->create_from_surface(mainMesh, 0);

			minDist = pointDist(guidingVector, guidingVectorOrigin, mainMeshMdt->get_vertex(0));
			maxDist = minDist;
			float currentDist = 0.0f;
			for (int i(1) ; i  < mainMeshMdt->get_vertex_count() ; i++)
			{
				currentDist = pointDist(guidingVector, guidingVectorOrigin, mainMeshMdt->get_vertex(i));
				minDist = std::min(minDist, currentDist);
				maxDist = std::max(maxDist, currentDist);
			}

			mainMeshDist = maxDist - minDist;

			repeatMeshFromMdtToMeshIns(mainMeshMdt, curvedMesh, meshRepetitonsNumber, mainMeshDist, curvedMeshMdt);
			curveMainMesh(get_curve(), curvedMeshStartingOffset);
		}
	}
}

void MeshCurver::updateCurve()
{
	godot::Ref<godot::Curve3D> curve = this->get_curve();

	if (prevCurve->get_point_count() != 0 && curve->get_point_count() != 0)
	{
		if (prevCurve->get_point_count() < curve->get_point_count())//A vertex was added
		{
			if (prevCurve->get_point_position(prevCurve->get_point_count()-1) != curve->get_point_position(curve->get_point_count()-1))
			{
				if (updateLowerBound == -1)
				{
					updateLowerBound = std::max(0, static_cast<int>(curve->get_point_count()-2));
				}
				else
				{
					updateLowerBound = std::min(updateLowerBound, static_cast<int>(curve->get_point_count()-2));
				}
			}
			else
			{
				for (int i(0) ; i < prevCurve->get_point_count() ; i++)
				{
					if (prevCurve->get_point_position(i) != curve->get_point_position(i))
						if (updateLowerBound == -1)
						{
							updateLowerBound = std::max(0,i-1);
						}
						else
						{
							updateLowerBound = std::min(updateLowerBound,i-1);
						}
						break;
				}
			}
		}
		else if (prevCurve->get_point_count() > curve->get_point_count())
		{
			if (prevCurve->get_point_position(prevCurve->get_point_count()-1) != curve->get_point_position(curve->get_point_count()-1))
				if (updateLowerBound == -1)
				{
					updateLowerBound = std::max(0, static_cast<int>(curve->get_point_count()-1));
				}
				else
				{
					updateLowerBound = std::min(updateLowerBound, static_cast<int>(curve->get_point_count()-1));
				}
			else
			{
				for (int i(0) ; i < prevCurve->get_point_count() ; i++)
				{
					if (prevCurve->get_point_position(i) != curve->get_point_position(i))
					{
						if (updateLowerBound == -1)
						{
							updateLowerBound = std::max(0,i-1);
						}
						else
						{
							updateLowerBound = std::min(updateLowerBound,i-1);
						}
						break;
					}
				}
			}
		}
		else//Same vertices count, but there was change
		{
			for (int i(0) ;  i < prevCurve->get_point_count() ; i++)
			{
				if (prevCurve->get_point_in(i) != curve->get_point_in(i) 
				|| prevCurve->get_point_out(i) != curve->get_point_out(i) 
				|| prevCurve->get_point_position(i) != curve->get_point_position(i) 
				|| prevCurve->get_point_tilt(i) != curve->get_point_tilt(i))
					if (updateLowerBound == -1)
						updateLowerBound = std::max(0,i-1);
					else
						updateLowerBound = std::min(updateLowerBound,i);
					break;
			}
		}
	}
	
	prevCurve = curve->duplicate();
}

void MeshCurver::curveMainMesh(godot::Ref<godot::Curve3D> guidingCurve, float startingOffset, int updateFromVertexOfId)
{
	if (has_node("curvedMesh") && beforeCurveMdt->get_vertex_count() != 0 && get_curve()->get_point_count() != 0)
	{
		float alpha = 0.0f;
		float beta = 0.0;
		godot::Vector3 originalVertex  = godot::Vector3(0,0,0);
		float vertexCurveOffset = 0.0f;
		float minOffset = curvePointIdToOffset(updateFromVertexOfId, guidingCurve);
			
		for (int vertexIndex(0) ;  vertexIndex < beforeCurveMdt->get_vertex_count() ; vertexIndex++)
		{
			originalVertex = beforeCurveMdt->get_vertex(vertexIndex);
			//The offset of the vertex on the curve
			vertexCurveOffset = xyzScale.x * std::min(static_cast<float>(guidingCurve->get_baked_length()/xyzScale.x), startingOffset + pointDist(guidingVector, guidingVectorOrigin, originalVertex) - minDist);
			
			if (vertexCurveOffset >= minOffset)
			{
				alpha = xyzScale.y * originalVertex.y;
				beta = xyzScale.z * originalVertex.z;
				curvedMeshMdt->set_vertex(vertexIndex, guidingCurve->interpolate_baked(vertexCurveOffset) + alpha * getUpFromOffset(vertexCurveOffset) + beta * getNormalFromOffset(vertexCurveOffset));
			}
		}

		godot::Ref<godot::ArrayMesh> test;
		test.instance();
		curvedMeshMdt->commit_to_surface(test);
		curvedMesh->set_mesh(test);
		curvedMesh->get_children().empty();
	}
}

void MeshCurver::repeatMeshFromMdtToMeshIns(godot::Ref<godot::MeshDataTool> sourceMdt, godot::MeshInstance* targetMeshInstance, int repetitions, float meshSize, godot::Ref<godot::MeshDataTool> meshInstanceMdt)
{
	if (has_node("curvedMesh") && has_node("Utilities"))
	{	
		
		/*targetSt->begin(godot::Mesh::PRIMITIVE_TRIANGLES);
		
		int currentVertexId = 0;
		
		for (int meshNumber(0) ; meshNumber < repetitions ; meshNumber++)
		{
			for (int faceNumber(0) ; faceNumber < sourceMdt->get_face_count() ; faceNumber++)
			{
				for (int faceVertexNumber(0) ; faceVertexNumber < 3 ; faceVertexNumber++)
				{
					//We go through every face, and then every 3 vertices in those faces
					currentVertexId = sourceMdt->get_face_vertex(faceNumber, faceVertexNumber);

					targetSt->add_color(sourceMdt->get_vertex_color(currentVertexId));
					targetSt->add_normal(sourceMdt->get_vertex_normal(currentVertexId));
					targetSt->add_uv(sourceMdt->get_vertex_uv(currentVertexId));
					targetSt->add_vertex(guidingVector*meshNumber*meshSize + sourceMdt->get_vertex(currentVertexId));
				}
			}
		}

		targetSt->commit();

		meshInstanceMdt->create_from_surface(targetMeshInstance->get_mesh(), 0);
		beforeCurveMdt->create_from_surface(targetMeshInstance->get_mesh(), 0);*/
	}
}

float MeshCurver::curvePointIdToOffset(int idx, godot::Ref<godot::Curve3D> targetCurve)
{
	if (idx == INFINITY)
		return INFINITY;
	else if (idx == -INFINITY)
		return -INFINITY;
	else
		return(targetCurve->get_closest_offset(targetCurve->get_point_position(idx)));	
}

void MeshCurver::setMeshRepetitions(int newValue)
{
	if (has_node("curvedMesh"))
	{
		if (newValue >= 1)
		{
			meshRepetitonsNumber = newValue;
			repeatMeshFromMdtToMeshIns(mainMeshMdt, curvedMesh, meshRepetitonsNumber, mainMeshDist, curvedMeshMdt);
			curveMainMesh(get_curve(), curvedMeshStartingOffset);
		}
	}
}

void MeshCurver::generateBoundingBox(bool newValue)
{
	if (has_node("curvedMesh"))
	{
		curvedMesh->get_children().empty();

		curvedMesh->create_trimesh_collision();
	}
}

float MeshCurver::pointDist(godot::Vector3 planeNormal, godot::Vector3 normalOrigin, godot::Vector3 point)
{
	return planeNormal.x * (point.x - normalOrigin.x) + planeNormal.y * (point.y - normalOrigin.y) + planeNormal.z * (point.z - normalOrigin.z);
}

godot::Vector3 MeshCurver::getTangentFromOffset(float offset)
{
	return ((get_curve()->interpolate_baked(offset+epsilon) - get_curve()->interpolate_baked(offset-epsilon))/2).normalized();
}

	
godot::Vector3 MeshCurver::getUpFromOffset(float offset)
{
	if (enableUpVector)
		return get_curve()->interpolate_baked_up_vector(offset);
	else
		return Vector3(0,1,0);
}

		
godot::Vector3 MeshCurver::getNormalFromOffset(float offset)
{
	return getNormalFromUpAndTangent(getUpFromOffset(offset), getTangentFromOffset(offset));
}
	
godot::Vector3 MeshCurver::getNormalFromUpAndTangent(godot::Vector3 up, godot::Vector3 tangent)
{
	float x = up.x;
	float y = up.y;
	float z = up.z;
	float t = tangent.x;
	float u = tangent.y;
	float v = tangent.z;
	Vector3 ret = Vector3();

	if (y*t-u*up.x != 0)
	{
		float c = ((y*t-u*up.x) < 0 ? -1.0f : 1.0f);
		float b = c*(v*x-z*t)/(y*t-u*up.x);
		float a = c*(z*u-y*v)/(y*t-u*up.x);
		ret = Vector3(a,b,c).normalized();
	}
	else
	{
		if (t != 0)
		{
			float b = t;
			float a = -b * u / t;

			ret = Vector3(a,b,0.0).normalized();
		}
		else
		{
			if (x != 0)
			{
				float b = x;
				float a = -b * y / x;
				ret = Vector3(a,b,0.0).normalized();
			}
			else
			{
				ret = Vector3(1.0,0.0,0.0);
			}
		}
	}


	return ret;
}
	