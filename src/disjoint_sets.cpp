#include "disjoint_sets.hpp"

using namespace godot;

int DisjointSets::count_sets() const {
   return num_sets;
}
NO_ERROR_CHECK int DisjointSets::get_set_size(Set S) const {
   return sizes[ find_root(S) ];
}
NO_ERROR_CHECK DisjointSets::Set DisjointSets::find_root(Set S) const {
   return S == parents[S] ? S : find_root( parents[S] );
}
void DisjointSets::reset() {
   sizes.fill(1);

   for (int n = 0; n < parents.size(); ++n) {
      parents.set(n, n);
   }
}
DisjointSets::Set DisjointSets::new_set() {
   int set = parents.size();

   ++num_sets;
   parents.push_back(set);
   sizes.push_back(1);
   return set;
}
NO_ERROR_CHECK void DisjointSets::merge(Set A, Set B) {
   A = find_root(A);
   B = find_root(B);

   if (A == B) return;

   int net_size = sizes[A] + sizes[B];

   --num_sets;
   if (sizes[A] <= sizes[B]) {
      parents.set(A, B);
      sizes.set(B, net_size);
   } else {
      parents.set(B, A);
      sizes.set(A, net_size);
   }
}