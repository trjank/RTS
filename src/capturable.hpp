#ifndef CAPTURABLE_HPP
#define CAPTURABLE_HPP

// This prevents circular includes
struct Capturable {
   virtual bool can_capture() = 0;
   virtual double get_alloy_per_sec() = 0;
   virtual double get_energy_per_sec() = 0;
};

#endif // CAPTURABLE_HPP