# Model Content

## Business Layer

![Business Layer Metamodel](http://pubs.opengroup.org/architecture/archimate2-doc/ts_archimate_2.1_files/image014.jpg)

* Active Structure Concepts
  - Business Actor
  - Business Role
  - Business Collaboration
  - Business Interface
  - Location
* Behavioral Concepts
  - Business Process
  - Business Function
  - Business Interaction
  - Business Event
  - Business Service
* Passive Structure Concepts
  - Business Object
  - Representation
  - Meaning
  - Value
  - Product
  - Contract
* Summary of Business Layer Concepts

## Application Layer

* Application Layer Metamodel
* Active Structure Concepts
  - Application Component
  - Application Collaboration
  - Application Interface
* Behavioral Concepts
  - Application Function
  - Application Interaction
  - Application Service
* Passive Structure Concepts
  - Data Object
* Summary of Application Layer Components

## Technology Layer

* Technology Layer Metamodel
* Active Structure Concepts
  - Node
  - Device
  - System Software
  - Infrastructure Interface
  - Network
  - Communication Path
* Behavioral Concepts
  - Infrastructure Function
  - Infrastructure Service
* Passive Structure Concepts
  - Artifact
* Summary of Technology Layer Concepts

## Cross-Layer Dependencies

* Business Layer and Lower Layers Alignment
* Application-Technology Alignment

## Relationships

* Structural Relationships
  - Composition Relationship
  - Aggregation Relationship
  - Assignment Relationship
  - Realization Relationship
  - Used By Relationship
  - Access Relationship
  - Association Relationship
* Dynamic Relationships
  - Triggering Relationship
  - Flow Relationship
* Other Relationships
  - Grouping
  - Junction
  - Specialization Relationship
* Summary of Relationships
* Derived Relationships

## Architecture Viewpoints

* Introduction
* Views, Viewpoints, and Stakeholders
* Viewpoint Classification
* Standard Viewpoints in ArchiMate
  - Introductory Viewpoint
  - Organization Viewpoint
  - Actor Co-operation Viewpoint
  - Business Function Viewpoint
  - Business Process Viewpoint
  - Business Process Co-operation Viewpoint
  - Product Viewpoint
  - Application Behavior Viewpoint
  - Application Co-operation Viewpoint
  - Application Structure Viewpoint
  - Application Usage Viewpoint
  - Infrastructure Viewpoint
  - Infrastructure Usage Viewpoint
  - Implementation and Deployment Viewpoint
  - Information Structure Viewpoint
  - Service Realization Viewpoint
  - Layered Viewpoint
  - Landscape Map Viewpoint

## Language Extension Mechanisms

* Adding Attributes to ArchiMate Concepts and Relationships
* Specialization of Concepts and Relationships

## Motivation Extension

* Motivation Aspect Metamodel
* Motivational Concepts
  - Stakeholder
  - Driver
  - Assessment
  - Goal
  - Requirement
  - Constraint
  - Principle
  - Summary of Motivational Concepts
* Relationships
  - Association Relationship
  - Aggregation Relationship
  - Realization Relationship
  - Influence Relationship
  - Summary of Relationships
* Cross-Aspect Dependencies
* Viewpoints
  - Stakeholder Viewpoint
  - Goal Realization Viewpoint
  - Goal Contribution Viewpoint
  - Principles Viewpoint
  - Requirements Realization Viewpoint
  - Motivation Viewpoint

## Implementation and Migration Extension

* Implementation and Migration Extension Metamodel
* Implementation and Migration Concepts
  - Work Package
  - Deliverable
  - Plateau
  - Gap
  - Summary of Implementation and Migration Concepts
* Relationships
* Cross-Aspect Dependencies
* Viewpoints
  - Project Viewpoint
  - Migration Viewpoint
  - Implementation and Migration Viewpoint

# Referenceable Entities

* Model
    - Element
    - Organization (sometimes! but not always)
    - PropertyDefinition
    - Relationship
    - Diagram
    - Viewpoint
        + Connection
        + ViewNode

# Array Contents

These are items that are stored in arrays:

AnyAttribute in:

* AnyElement
* Connection
* Diagram
* Element
* Model
* Organization
* PropertyDefinition
* Relationship
* ViewNode
* Viewpoint

AnyElement in:

* AnyElement
* Connection
* Diagram
* Element
* Model
* Organization
* PropertyDefinition
* Relationship
* SchemaInfo
* ViewNode
* Viewpoint

Concern in:

* Viewpoint

Connection in:

* Diagram
* ViewNode

Diagram in:

* Model
* Organization

LangString in:

* Concern

Element in:

* Model
* Organization

ElementType in:

* Viewpoint

Location in:

* Connection

ModelingNote in:

* Viewpoint

SchemaInfo in:

* Metadata

Organization in:

* Model

Property in:

* Connection
* Diagram
* Element
* Model
* Relationship
* ViewNode (though this is going to be deleted)

PropertyDefinition in:

* Model

Relationship in:

* Model
* Organization

RelationshipType in:

* Viewpoint

String in:

* Model (schema_locations)

ViewNode in:

* Diagram
* ViewNode

Viewpoint in:

* Model

ViewpointPurposeEnum in:

* Viewpoint

ViewpointContentEnum in:

* Viewpoint

---

Each relationship has exactly one ‘from’ and one ‘to’ concept (element, relationship, or relationship connector) as endpoints. The following restrictions apply:

•  No relationships are allowed between two relationships
•  All relationships connected with relationship connectors must be of the same type
•  A chain of relationships of the same type that connects two elements, and is in turn connected via relationship connectors, is valid only if a direct relationship of that same type between those two elements is valid
•  A relationship connecting an element with a second relationship can only be an aggregation, composition, or association; aggregation or composition are valid only from a composite element to that second relationship
For the sake of readability, the metamodel figures throughout this document do not show all possible relationships in the language. Section 5.6 describes a set of derivation rules to derive indirect relationships between elements in a model. Aggregation, composition, and specialization relationships are always permitted between two elements of the same type, and association is always allowed between any two elements, and between any element and relationship. The exact specification of permitted relationships is given in Appendix B.

