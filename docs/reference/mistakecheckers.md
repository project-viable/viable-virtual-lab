## Mistake Checkers
This refers to validating user actions against what is expected and considered correct in a lab.
## Types of Errors
In the simulation, there are a variety of possible things to check for, though they tend to resolve to two categories: general and lab-specific. 
### General
These may include configuring the `CurrentSource` wires incorrectly. This is something that a `LabObject` should be aware of and let the user know of their mistake.
### Lab-Specific
These include issues that are relevant to a specific lab. For instance, the run time of the gel in the Gel Electrophoresis module should not be something a `LabObject` like the `CurrentSource` or `ElectrolysisSetup` should be aware of.
## Implementation
The general structure relies on the Strategy Design Pattern where each separate `MistakeChecker` type implements the base `MistakeChecker` class.
### `MistakeChecker` functions
- `CheckAction(params: Dictionary)`: checks the action based off the parameters sent by `ReportAction()`. It should compare the `actionType` of `params` to determine whether it should do anything. It then should send a `LabLog` log, warn, or error depending on the requirements.
### `MistakeChecker` resource
To add a `MistakeChecker` to a lab module or even to the main scene so that it acts as a universal checker, it is necessary to create a resource. Once created, it is added to the `Check Strategies` array of the scene. <br>
As an example, refer to the image below. <br>
![image](./images/Example_CheckStrategies.png)