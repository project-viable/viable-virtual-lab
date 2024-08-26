## Mixtures
The simulation stores mixtures and their ingredients within `mixtures.json`.

When new mixtures are added to the simulation within different modules, their information should be stored here.

To add one, follow the format:
```
"MixtureName": {
  "substances": {
    "substanceName" {
      "volume": X // X refers to the volume in mL
    },
    .
    .
    .
  }
}
```