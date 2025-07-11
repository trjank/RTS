#ifndef DESTRUCTABLE_HPP
#define DESTRUCTABLE_HPP

// This prevents circular includes
struct Destructable {
   virtual int get_cost() const = 0;
   virtual double get_energy() const = 0;
};

#endif // CAPTURABLE_HPP