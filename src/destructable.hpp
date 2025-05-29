#ifndef DESTRUCTABLE_HPP
#define DESTRUCTABLE_HPP

/*------------------------------------------------------*
| This prevents circular includes                       |
*------------------------------------------------------*/
struct Destructable {
   virtual int get_cost() = 0;
   virtual float get_energy() = 0;
};

#endif // CAPTURABLE_HPP