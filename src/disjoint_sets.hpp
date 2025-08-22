#ifndef DISJOINT_SETS_HPP
#define DISJOINT_SETS_HPP

#include <godot_cpp/templates/vector.hpp>
#include "defaults.hpp"

namespace godot {

/*------------------------------------------------------|
| This is a standard implementation of a disjoint sets  |
| data structure. Great for unions and lookup, but does |
| not support removal.                                  |
|------------------------------------------------------*/
struct DisjointSets {
   typedef int Set;

   int count_sets() const;
   NO_ERROR_CHECK int get_set_size(Set S) const;
   NO_ERROR_CHECK Set find_root(Set S) const;
   void reset();
   Set new_set();
   /*------------------------------------------------------|
   | We have the choice to merge by size or by rank (tree  |
   | height). Since set size is generally more useful, we  |
   | keep the larger size set as the parent.               |
   |------------------------------------------------------*/
   NO_ERROR_CHECK void merge(Set A, Set B);
protected:
   int num_sets = 0;
   Vector<Set> parents;
   Vector<int> sizes;
};

}

#endif // DISJOINT_SETS_HPP