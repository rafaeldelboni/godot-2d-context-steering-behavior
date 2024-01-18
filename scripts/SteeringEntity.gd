extends CharacterBody2D

const SPEED = 600.0

var w := Vector2(-1, 0)     # 0
var wnw := w.rotated(PI/8)  # 1
var nw := Vector2(-1, -1)   # 2
var nnw := nw.rotated(PI/8) # 3
var n := Vector2(0, -1)     # 4
var nne := n.rotated(PI/8)  # 5
var ne := Vector2(1, -1)    # 6
var ene := ne.rotated(PI/8) # 7
var e := Vector2(1, 0)      # 8
var ese := e.rotated(PI/8)  # 9
var se := Vector2(1, 1)     # 10
var sse := se.rotated(PI/8) # 11
var s := Vector2(0, 1)      # 12
var ssw := s.rotated(PI/8)  # 13
var sw := Vector2(-1, 1)    # 14
var wsw := sw.rotated(PI/8) # 15

var directions : Array[Vector2] = [w, wnw, nw, nnw, n, nne, ne, ene, e, ese, se, sse, s, ssw, sw, wsw]

func get_pois() -> Array[Node]:
	return get_tree().get_nodes_in_group("poi")

func calculate_desire(entity: Node2D, poi: Node2D, direction: Vector2, max_distance: float) -> float:
	# TODO: consider distance of POI in the desire formula
	var entity_local_position = entity.to_local(entity.global_position)
	var poi_local_position = entity.to_local(poi.global_position)
	var distance_to_poi = entity_local_position.distance_to(poi_local_position)
	if (distance_to_poi < max_distance):
		var direction_to_poi = entity_local_position.direction_to(poi_local_position)
		var direction_normal = direction.normalized()
		var DOT = direction_to_poi.dot(direction_normal)
		var ANGLE = rad_to_deg(acos(DOT))
		var distance_desire = remap(distance_to_poi, max_distance, 0, 0, 1)
		var angle_desire = remap(ANGLE, 180, 0, 0, 1)
		return remap(distance_desire + angle_desire, 0, 2, 0, 1) * 150
	else:
		return 0.0

func _draw():
	for poi : Node2D in get_pois():
		for direction in directions:
			var entity_local_position = to_local(global_position)
			var desire = calculate_desire(self, poi, direction, 1000.0)
			draw_line(entity_local_position, direction.normalized() * desire, Color.GREEN, 2.0)

	# for direction in directions:
	# 	draw_line(to_local(global_position), direction.normalized() * 90, Color.GREEN, 2.0)

	for poi : Node2D in get_pois():
		draw_line(to_local(global_position), to_local(poi.global_position), Color.BLUE, 2.0)

func _process(_delta: float) -> void:
	queue_redraw()

func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
