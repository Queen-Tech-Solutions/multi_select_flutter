/// A model class used to represent a selectable item.
class MultiSelectItem<V> {
  const MultiSelectItem(this.value, this.label, this.image);

  final V value;
  final String label;
  final String image;
}