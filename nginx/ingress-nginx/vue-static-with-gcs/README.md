# vue static file hosted in GCS served by ingress-nginx

## Requirement
The URL Path from Vue MUST NOT contain dot (`.`), because this is how nginx gonna differentiate the resource while proxying.
For instances:
* :heavy_check_mark: __/api/v1/resources__
* :negative_squared_cross_mark: __/api/v1.something__
* :negative_squared_cross_mark: __/blabla.thing__