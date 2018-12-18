#ifndef MESHCURVER_HPP
#define MESHCURVER_HPP

#include <iostream>
#include <algorithm>
#include <locale>
#include <string>

#include <core/Godot.hpp>
#include <gen/Spatial.hpp>
#include <gen/Sprite.hpp>
#include <gen/Path.hpp>
#include <gen/Curve3D.hpp>
#include <gen/Mesh.hpp>
#include <gen/ArrayMesh.hpp>
#include <gen/MeshDataTool.hpp>
#include <gen/MeshInstance.hpp>
#include <gen/SurfaceTool.hpp>
#include <gen/Script.hpp>
#include <gen/File.hpp>

namespace godot{

class MeshCurver : public godot::Path {
	GODOT_CLASS(MeshCurver, Path);

	private:

		bool enableUpVector = true;
		godot::Ref<godot::ArrayMesh> mainMesh;
		int meshRepetitonsNumber = 1;
		float curvedMeshStartingOffset = 0.0f;
		bool createTrimeshStaticBody = false;
		godot::Vector3 xyzScale = Vector3(1,1,1);

		float epsilon = 0.2f;
		float debugRaysInterval = 2.0f;
		float minDist = 0.0f;
		float maxDist = 0.0f;
		float mainMeshDist = 0.0f;

		godot::Vector3 guidingVectorOrigin = Vector3(0,0,0);
		godot::Vector3 guidingVector = Vector3(1,0,0);

		godot::Ref<godot::MeshDataTool> mainMeshMdt;
		godot::Ref<godot::MeshDataTool> beforeCurveMdt;
		godot::Ref<godot::MeshDataTool> curvedMeshMdt;

		godot::Ref<godot::Curve3D> prevCurve;
		int updateLowerBound = -1;
		float updateFrequency = 0.001f;
		float deltaSum = 0.0f;

		godot::MeshInstance* curvedMesh;
		godot::Node* utilities;

		godot::Ref<godot::SurfaceTool> targetSt;

	public:
		static void _register_methods();

		void _init();
		void _process(float delta);

		//Setters and getters
		void setEnableUpVector(bool newValue) {enableUpVector = newValue;};
		bool getEnableUpVector() const {return enableUpVector;};

		void updateMesh(godot::Ref<godot::ArrayMesh> newMesh);
		godot::Ref<godot::ArrayMesh> getMainMesh() const {return mainMesh;};

		void setMeshRepetitions(int newValue);
		int getMeshRepetitions() const {return meshRepetitonsNumber;};
		void setMeshOffset(float newOffset) {curvedMeshStartingOffset = newOffset;};
		float getMeshOffset() const {return curvedMeshStartingOffset;};
		void generateBoundingBox(bool newValue);
		bool getNothing() const {return false;};
		void setXYZScale(godot::Vector3 newScale) {xyzScale = newScale; curveMainMesh(get_curve(), curvedMeshStartingOffset, updateLowerBound);};
		godot::Vector3 getXYZSCale() const {return xyzScale;};

		void updateCurve();
		void curveMainMesh(godot::Ref<godot::Curve3D> guidingCurve, float startingOffset = 0.0f, int updateFromVertexOfId = 0);

		void recalculateDebugRayCasts() {};

		float curvePointIdToOffset(int idx, godot::Ref<godot::Curve3D> targetCurve);

		float pointDist(godot::Vector3 planeNormal, godot::Vector3 normalOrigin, godot::Vector3 point);
		godot::Vector3 getTangentFromOffset(float offset);
		godot::Vector3 getUpFromOffset(float offset);
		godot::Vector3 getNormalFromOffset(float offset);
		godot::Vector3 getNormalFromUpAndTangent(godot::Vector3 up, godot::Vector3 tangent);
}; 

}

#endif