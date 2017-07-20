# JSON Schema for PHP

A PHP Implementation for validating `JSON` Structures against a given `Schema`.

See [json-schema](http://json-schema.org/) for more details.

## Installation

```
composer install
```
### Having trouble installing composer
  1. Mac
  
    ```
    brew update
    brew tap homebrew/dupes
    brew tap homebrew/php
    brew install php56
    brew install composer
    ```
  
## Usage

```
cd ekstep
php validate.php <path to your data file>
```

## Schema
The schema files should be kept at ../../schema/v&lt;schema version&gt; and should be named as:
* file name should be all lowercase
* file name should exactly match the event type. eg: be_object_lifecycle, cp_interact
* file should have dot json extension
