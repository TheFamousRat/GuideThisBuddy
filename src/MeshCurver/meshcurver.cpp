
#include "meshcurver.hpp"

using namespace godot;

void MeshCurver::_register_methods() 
{
	godot::register_method("_process", &MeshCurver::_process);

	godot::register_method("pointDist", &MeshCurver::pointDist);
	godot::register_method("getTangentFromOffset", &MeshCurver::getTangentFromOffset);
	godot::register_method("getUpFromOffset", &MeshCurver::getUpFromOffset);
	godot::register_method("getNormalFromOffset", &MeshCurver::getNormalFromOffset);
	godot::register_method("getNormalFromUpAndTangent", &MeshCurver::getNormalFromUpAndTangent);

	godot::register_method("updateMainMesh", &MeshCurver::updateMainMesh);
	godot::register_method("curverFromMesh", &MeshCurver::curverFromMesh);
	godot::register_method("meshInstanceCurver", &MeshCurver::meshInstanceCurver);

	godot::register_method("currentMeshLength", &MeshCurver::currentMeshLength);
}

void MeshCurver::_process(float delta)
{
	
}

void MeshCurver::_init()
{
	epsilon = 0.1f;
	std::cout << "I got initialized\n";
	mainMdt.instance();
	meshInstanceMdt.instance();
}

float MeshCurver::pointDist(godot::Vector3 planeNormal, godot::Vector3 normalOrigin, godot::Vector3 point) const
{
	return planeNormal.x * (point.x - normalOrigin.x) + planeNormal.y * (point.y - normalOrigin.y) + planeNormal.z * (point.z - normalOrigin.z);
}

godot::Vector3 MeshCurver::getTangentFromOffset(godot::Ref<Curve3D> curve, float offset, bool cubic) const
{
	godot::Vector3 p0 = curve->interpolate_baked(offset - epsilon, cubic);
	godot::Vector3 p1 = curve->interpolate_baked(offset, cubic);
	godot::Vector3 p2 = curve->interpolate_baked(offset + epsilon, cubic);
	godot::Vector3 tangEst = (((p1-p0)+(p2-p1))/2).normalized();
	return tangEst;
}

	
godot::Vector3 MeshCurver::getUpFromOffset(godot::Ref<Curve3D> curve, float offset) const
{
	if (curve->is_up_vector_enabled())
		return curve->interpolate_baked_up_vector(offset);
	else
		return Vector3(0,1,0);
}

		
godot::Vector3 MeshCurver::getNormalFromOffset(godot::Ref<Curve3D> curve, float offset) const
{
	godot::Vector3 up = getUpFromOffset(curve, offset);
	godot::Vector3 tang = getTangentFromOffset(curve, offset);

	return getNormalFromUpAndTangent(up, tang);
}
	
godot::Vector3 MeshCurver::getNormalFromUpAndTangent(godot::Vector3 up, godot::Vector3 tangent) const
{
	float x = up.x;
	float y = up.y;
	float z = up.z;
	float t = tangent.x;
	float u = tangent.y;
	float v = tangent.z;

	godot::Vector3 ret;
	
	if (y*t-u*x != 0)
	{
		float c= ((y*t - u*x) < 0 ? -(1.0f) : (1.0f));
		float b = c*(v*x-z*t)/(y*t-u*x);
		float a = c*(z*u-y*v)/(y*t-u*x);
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

void MeshCurver::updateMainMesh(godot::Ref<godot::ArrayMesh> mainMesh)
{
	mainMdt->create_from_surface(mainMesh, 0);

	if (mainMdt->get_vertex_count() > 0)
	{
		minDist = pointDist(Vector3(1,0,0),Vector3(0,0,0),mainMdt->get_vertex(0));
		maxDist = minDist;

		for (int i(1) ; i < mainMdt->get_vertex_count() ; i++)
		{
			minDist = std::min(minDist, pointDist(Vector3(1,0,0),Vector3(0,0,0),mainMdt->get_vertex(i)));
			maxDist = std::max(maxDist, pointDist(Vector3(1,0,0),Vector3(0,0,0),mainMdt->get_vertex(i)));
		}
	}
}

float MeshCurver::currentMeshLength() const
{
	return maxDist - minDist;
}

void MeshCurver::curverFromMesh(godot::Ref<godot::Curve3D> targetCurve, godot::Ref<godot::ArrayMesh> meshToPlace, float startingOffset)
{
	godot::Ref<godot::MeshDataTool> curverMdt;
	curverMdt.instance();
	curverMdt->create_from_surface(meshToPlace, 0);

	float alpha = 0.0f;
	float beta = 0.0f;
	float pointOffset = 0.0f;
	godot::Vector3 currentVertex;
	godot::Vector3 curveUp;
	godot::Vector3 curveNormal;

	for (int i(0) ; i < curverMdt->get_vertex_count() ; i++)
	{
		alpha = curverMdt->get_vertex(i).y;
		beta = curverMdt->get_vertex(i).z;
		currentVertex = curverMdt->get_vertex(i);
		pointOffset = startingOffset + pointDist(godot::Vector3(1,0,0),godot::Vector3(0,0,0),currentVertex);
		curveUp = targetCurve->interpolate_baked_up_vector(pointOffset);
		curveNormal = getNormalFromUpAndTangent(curveUp, getTangentFromOffset(targetCurve, pointOffset));

		curverMdt->set_vertex(i, targetCurve->interpolate_baked(pointOffset) + alpha * curveUp + beta * curveNormal);
	}

	curverMdt->commit_to_surface(meshToPlace);
}

void MeshCurver::meshInstanceCurver(godot::Ref<godot::Curve3D> targetCurve, godot::Ref<godot::ArrayMesh> meshToPlace, int repetitionsNumber, float startingOffset)
{
	meshInstanceMdt->create_from_surface(meshToPlace, 0);

	float alpha = 0.0f;
	float beta = 0.0f;
	float pointOffset = 0.0f;
	godot::Vector3 currentVertex;
	godot::Vector3 curveUp;
	godot::Vector3 curveNormal;

	float meshLength = currentMeshLength();

	std::cout << mainMdt->get_vertex_count() << '\n';

	for (int j(0) ; j < repetitionsNumber ; j++)
	{
		for (int i(0) ; i < meshInstanceMdt->get_vertex_count() ; i++)
		{
			alpha = meshInstanceMdt->get_vertex(i).y;
			beta = meshInstanceMdt->get_vertex(i).z;
			currentVertex = meshInstanceMdt->get_vertex(i);
			pointOffset = startingOffset + j * meshLength + pointDist(godot::Vector3(1,0,0),godot::Vector3(0,0,0),currentVertex);
			curveUp = targetCurve->interpolate_baked_up_vector(pointOffset);
			curveNormal = getNormalFromUpAndTangent(curveUp, getTangentFromOffset(targetCurve, pointOffset));

			meshInstanceMdt->set_vertex(i, targetCurve->interpolate_baked(pointOffset) + alpha * curveUp + beta * curveNormal);
		}
	
	}

	meshInstanceMdt->commit_to_surface(meshToPlace);
}

