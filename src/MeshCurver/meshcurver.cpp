
#include "meshcurver.hpp"

using namespace godot;

void MeshCurver::_register_methods() 
{
	godot::register_property("showDebugRays", &MeshCurver::setDebugRaysVisibility, &MeshCurver::getDebugRaysVisibility, false);
	godot::register_property("enableUpVector", &MeshCurver::setEnableUpVector, &MeshCurver::getEnableUpVector, true);
	godot::register_property("meshRepetitonsNumber", &MeshCurver::setMeshRepetitions, &MeshCurver::getMeshRepetitions, 1);
	godot::register_property("curvedMeshStartingOffset", &MeshCurver::setMeshOffset, &MeshCurver::getMeshOffset, 0.0f);
	godot::register_property("createTrimeshStaticBody", &MeshCurver::generateBoundingBox, &MeshCurver::getNothing, false);
	godot::register_property("xyzScale", &MeshCurver::setXYZScale, &MeshCurver::getXYZSCale, Vector3(1,1,1));

	godot::Ref<godot::ArrayMesh> defaultMesh;
	defaultMesh.instance();
	godot::register_property<MeshCurver, godot::Ref<godot::ArrayMesh>>("mainMesh", &MeshCurver::updateMesh, &MeshCurver::getMainMesh, defaultMesh);

	godot::register_method("_process", &MeshCurver::_process);

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
			if (showDebugRays)
				recalculateDebugRayCasts();

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

	godot::MeshInstance *curvedMesh = new godot::MeshInstance();
	add_child(curvedMesh);
}

void MeshCurver::updateMesh(godot::Ref<godot::ArrayMesh> newMesh)
{
	if (newMesh.is_valid())
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