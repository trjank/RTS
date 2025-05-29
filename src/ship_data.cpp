#include "ship_data.hpp"

/*------------------------------------------------------*
|                                                       |
|            ______              __         __          |
|           / __/ /____ ________/ /_ _____ / /_         |
|          _\ \/ __/ _ `/ __/ _  / // (_-</ __/         |
|         /___/\__/\_,_/_/  \_,_/\_,_/___/\__/          |
|                                                       |
|                     ship_data.cpp                     |
|                                                       |
*------------------------------------------------------*/

Ref<ShipData> ShipData::load(String csv_path) {

}
void ShipData::save(String csv_path) {
   // Ref<FileAccess> csv = FileAccess::open(csv_path, FileAccess::WRITE);
   // csv->store_csv_line(csv_columns);
   // for (Part* const part: parts) {
   //    ERR_FAIL_COND(part == nullptr);
   //    csv->store_csv_line(to_csv_line(part));
   // }
   // csv->close();
}
PackedStringArray ShipData::to_csv_line(Part* part) {
   return {};
   // // ID,rotation,x,y
   // Vector2 position = part->get_position();
   // int rotation = part->get_rotation_degrees() / 90;
   // return {
   //    String::num_int64(part->ID),
   //    String::num_int64(rotation),
   //    String::num(position.x),
   //    String::num(position.y)
   // };
}

ShipData::State ShipData::get_state() {
   return state;
}
int ShipData::get_cost() {
   return cost;
}
float ShipData::get_max_warp() {
   return max_warp;
}
float ShipData::get_max_HP() {
   return max_HP;
}
float ShipData::get_max_shield() {
   return max_shield;
}
float ShipData::get_max_energy() {
   return max_energy;
}