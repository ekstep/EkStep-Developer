# JSON Schema for PHP

A PHP Implementation for validating `JSON` Structures against a given `Schema`.

See [json-schema](http://json-schema.org/) for more details.

## Installation

```
composer install
```

## Usage

```
cd ekstep
php validate.php <path to your data file>
```

## Schema
The schema files should be kept ../../schema/v<schema version> and should be named as:
* file name should be all lowercase
* file name should exactly match the event type. eg: be_object_lifecycle, cp_interact
* file should have dot json extension
