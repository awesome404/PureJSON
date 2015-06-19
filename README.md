# PureJSON
PureJSON uses throw/catch error handling introduced in Swift 2.0. All of the JSON types are hidden behind (and derived from) the JSONAny class. The JSONAny class has all the methods for every type, but only the right ones are overridden in each subclass. This leaves the super class implementations to handle errors. All data is stored as Swift types and not NS types (why I named it PureJSON).

Documentation will be maintained in the Playground. (And pasted here)
