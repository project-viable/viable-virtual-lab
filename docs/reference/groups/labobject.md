## LabObject Groups

All `LabObject`s have groups they can have. These groups indicate functions they should implement in their script.

| Group Name | Function(s) | Notes |
| ------------- | ------------- | ------------- |
| LabObject | See [LabObjects](/docs/reference/labobject.md) | Do not add an object to this group manually. Extend the `LabObject` base class. |
| Container | AddContents(), TakeContents(), CheckContents() | |
| Heatable | heat() | |
| Chillable | chill() | |
| Conductive | run_current() | |
| Disposable-Hazard | _none_ | Used as a tag to indicate that this object can be put into a biohazard disposal bin. Uses the normal `LabObject.dispose()` function. |