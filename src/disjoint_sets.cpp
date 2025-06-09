#include "disjoint_sets.hpp"

using namespace godot;

int DisjointSets::count_num_sets() {
   return num_sets;
}
int DisjointSets::new_set() {
   ++num_sets;
   // Define sets by their index
   int set = parents.size();
   parents.push_back(set);
   sizes.push_back(1);
   return set;
}
int DisjointSets::find_root(int set) {
   return set == parents[set] ? set : find_root(parents[set]);
}
void DisjointSets::merge(int A, int B) {
   --num_sets;
   A = find_root(A);
   B = find_root(B);
   if (A == B) return;
   int net_size = sizes[A] + sizes[B];
   // Keep the larger set as the root
   if (sizes[A] < sizes[B]) {
      parents.set(A, B);
      sizes.set(B, net_size);
   } else {
      parents.set(B, A);
      sizes.set(A, net_size);
   }
}