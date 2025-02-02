class_name CustomPhysics extends RigidBody2D

func _integrate_forces(state):
	return
   #Vector2 net_force = force - friction * velocity;
   #velocity += (net_force / mass) * dt;
   #set_position(get_position() + velocity * dt);
   #force = constant_force;
