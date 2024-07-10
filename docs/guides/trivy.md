# Moving towards configuration scanning with Trivy
Overtime we've taken [trivy][trivy] to be the go-to scanning tool for a variety of things. This also includes terraform scanning.

This section describes some differences between Trivy and tfsecurity.

| Feature              | Trivy                                                  | tfsecurity                |
|----------------------|--------------------------------------------------------|----------------------|
| Policy Distribution | Embedded and Updated via Registry                      | Embedded             |
| Custom Policies      | Rego                                                   | Rego, JSON, and YAML |
| Supported Formats    | Dockerfile, JSON, YAML, Terraform, CloudFormation etc. | Terraform  Only      |


# Comparison with examples
## Simple scan
### With Trivy
```shell
$ trivy config <dir>
```
### With tfsecurity
```shell
$ tfsecurity <dir>
```

## Passing tfvars
### With Trivy
```shell
$ trivy --tf-vars <vars.tf> <dir>
```
### With tfsecurity
```shell
$ tfsecurity <dir> --tf-vars-file <vars.tf>
```

## Report formats
### With Trivy
```shell
$ trivy config --format <format-type> <dir>
```

### With tfsecurity
```shell
$ tfsecurity <dir> --format <format-type>
```

We welcome any feedback if you find features that today are not available with Trivy misconfigration scanning that are available in tfsecurity. 

[trivy]: https://github.com/aquasecurity/trivy
