#include "disjoint_sets.hpp"

using namespace godot;

int DisjointSets::count_num_sets() const {
   return num_sets;
}
NO_ERROR_CHECK int DisjointSets::get_set_size(int S) const {
   return sizes[find_root(S)];
}
NO_ERROR_CHECK int DisjointSets::find_root(int S) const {
   return parents[S] == S ? S : find_root(parents[S]);
}
void DisjointSets::reset() {
   sizes.fill(1);
   for (int S = 0; S < parents.size(); ++S) {
      parents.set(S, S);
   }
}
int DisjointSets::new_set() {
   ++num_sets;
   int set = parents.size();
   parents.push_back(set);
   sizes.push_back(1);
   return set;
}
NO_ERROR_CHECK void DisjointSets::merge(int A, int B) {
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