#ifndef SELECTABLE_HPP
#define SELECTABLE_HPP

class Selectable {
  bool selected;
public:
  virtual void on_select() {};
  virtual void on_deselect() {};
  bool is_selected() { return selected; };
  friend class MouseCommands;
};

#endif // SELECTABLE_HPP