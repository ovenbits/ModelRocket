import ModelRocket

/*:
The **Vehicle** object has four properties, one of
which is required (when using the `strictJSON` initializer).

The underlying value on `Property` is always Optional. However, if the property
is required and the `strictJSON` initializer is used, `value` can be force
unwrapped safely, since the object will be created iff all properties where
`required == true` are found in the JSON object

*/

class Vehicle: Model {
    let model = Property<String>(key: "model")
    let year = Property<Int>(key: "year")
    let color = Property<UIColor>(key: "color")
    let availableColors = PropertyArray<UIColor>(key: "available_colors")
    let availableTrims = PropertyDictionary<Int>(key: "available_trims")
/*:
If you would like to avoid the use of `.value` to retrieve
the underlying value of a `Property`, a good pattern to use
is defining the `Property<T>` property as `private` (prefixed with a _)
and declaring a separate, `public` property of type `T`
*/
    private let _make = Property<String>(key: "make", required: true)
    var make: String {
        set { _make.value = newValue }
        get { return _make.value ?? "" }
    }
}

let json = JSON(data: dataFromResource())
if let vehicle = Vehicle(strictJSON: json) {
    vehicle.make
    vehicle.model.value
    vehicle.year[]
    
    for color in vehicle.availableColors {
        print("Color: \(color)")
    }
    
    for (key, value) in vehicle.availableTrims {
        print("Trim \(key) : \(value)")
    }
}
