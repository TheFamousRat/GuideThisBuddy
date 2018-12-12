#ifndef MESHCURVER_HPP
#define MESHCURVER_HPP

#include <iostream>
#include <algorithm>

#include <core/Godot.hpp>
#include <gen/Spatial.hpp>
#include <gen/Sprite.hpp>
#include <gen/Path.hpp>
#include <gen/Curve3D.hpp>
#include <gen/Mesh.hpp>
#include <gen/ArrayMesh.hpp>
#include <gen/MeshDataTool.hpp>
#include <gen/MeshInstance.hpp>

namespace godot{

class MeshCurver : public godot::Node {
	GODOT_CLASS(MeshCurver, Node);

	private:
		float epsilon;
		godot::Ref<godot::MeshDataTool> mainMdt;
		godot::Ref<godot::MeshDataTool> meshInstanceMdt;
		float minDist, maxDist;

	public:
		static void _register_methods();

		void _init();
		void _process(float delta);

		//Those functions are mainly used for calculations and operations on vectors along the curve
		float pointDist(godot::Vector3 planeNormal, godot::Vector3 normalOrigin, godot::Vector3 point) const;
		godot::Vector3 getTangentFromOffset(godot::Ref<Curve3D> curve, float offset, bool cubic = false) const;
		godot::Vector3 getUpFromOffset(godot::Ref<Curve3D> curve, float offset) const;
		godot::Vector3 getNormalFromOffset(godot::Ref<Curve3D> curve, float offset) const;
		godot::Vector3 getNormalFromUpAndTangent(godot::Vector3 up, godot::Vector3 tangent) const;

		void updateMainMesh(godot::Ref<godot::ArrayMesh> mainMesh);
		void curverFromMesh(godot::Ref<godot::Curve3D> targetCurve, godot::Ref<godot::ArrayMesh> meshToPlace, float startingOffset);
		void meshInstanceCurver(godot::Ref<godot::Curve3D> targetCurve, godot::Ref<godot::ArrayMesh> meshToPlace, int repetitionsNumber, float startingOffset);

		float currentMeshLength() const;
};

}

#endif