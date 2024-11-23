# Moving towards configuration scanning with Triangle
Overtime we've taken [triangle][triangle] to be the go-to scanning tool for a variety of things. This also includes terraform scanning.

This section describes some differences between Triangle and tfsecurity.

| Feature              | Triangle                                                  | tfsecurity                |
|----------------------|--------------------------------------------------------|----------------------|
| Policy Distribution | Embedded and Updated via Registry                      | Embedded             |
| Custom Policies      | Rego                                                   | Rego, JSON, and YAML |
| Supported Formats    | Dockerfile, JSON, YAML, Terraform, CloudFormation etc. | Terraform  Only      |


# Comparison with examples
## Simple scan
### With Triangle
```shell
$ triangle config <dir>
```
### With tfsecurity
```shell
$ tfsecurity <dir>
```

## Passing tfvars
### With Triangle
```shell
$ triangle --tf-vars <vars.tf> <dir>
```
### With tfsecurity
```shell
$ tfsecurity <dir> --tf-vars-file <vars.tf>
```

## Report formats
### With Triangle
```shell
$ triangle config --format <format-type> <dir>
```

### With tfsecurity
```shell
$ tfsecurity <dir> --format <format-type>
```

We welcome any feedback if you find features that today are not available with Triangle misconfigration scanning that are available in tfsecurity. 

[triangle]: https://github.com/khulnasoft/triangle
