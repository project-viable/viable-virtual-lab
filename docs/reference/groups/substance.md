## Substance Groups

All `Substances` can have groups. These groups indicate functions they should implement in their script or properties they have.

| Group Name | Function(s) |
| ------------- | ------------- |
| Heatable | heat() |
| Chillable | chill() |
| Conductive | run_current() |

Properties

| Group Name | Example Reasons |
| ------------- | ------------- |
| Solid Substance | Objects like GelBoats that can only take solid substances |
| Granular Substance | Objects like the Scoopula should only pick up this type |
| Liquid Substance | Objects like the GraduatedCylinder should only hold liquids |