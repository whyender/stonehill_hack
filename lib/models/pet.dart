class Pet {
final String id;
final String name;
final String breed;
final int age;
final String size; //large, mid. small accompanied w/ space requriements (yard reco or not)
final String energyLevel; //high, med, low acocmplaied w/ walking needs
final double price;
final String imageUrl;
final String description;
final String location; //in terms of distance and plac ewher eot pick up

Pet({
required this.id,
required this.name,
required this.breed,
required this.age,
required this.size,
required this.energyLevel,
required this.price,
required this.imageUrl,
required this.description,
required this.location,
});
}