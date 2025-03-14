# Migrating from tfsecurity to Trivy
Overtime we've taken [Trivy][trivy] to be the go-to scanning tool for a vareity of things. This also includes terraform scanning. For further information, have a look at the announcement ["tfsecurity is joining the Trivy family".](https://github.com/khulnasoft/tfsecurity/discussions/5)

### Main differences between Trivy and tfsecurity

Trivy's design keeps misconfiguration up to date automatically. New misconfiguration are updated in Trivy by pulling from the Container Registry. The embedded misconfiguration in Trivy are only used if Trivy cannot pull from the remote registry. See the [following documentation](https://khulnasoft.github.io/trivy/v0.41/docs/scanner/misconfiguration/policy/builtin/#policy-distribution) for further details.

## Comparison with examples
### Simple scan
#### With Trivy
```shell
$ trivy config <dir>
```
#### With tfsecurity
```shell
$ tfsecurity <dir>
```

The documentation can be found in Trivy under the [following link.](https://khulnasoft.github.io/trivy/latest/docs/scanner/misconfiguration/)

### Passing tfvars
#### With Trivy
```shell
$ trivy --tf-vars <vars.tf> <dir>
```
#### With tfsecurity
```shell
$ tfsecurity <dir> --tf-vars-file <vars.tf>
```

The documentation can be found in Trivy under the [following link.](https://khulnasoft.github.io/trivy/v0.41/docs/scanner/misconfiguration/#terraform-value-overrides)

### Report formats
#### With Trivy
```shell
$ trivy config --format <format-type> <dir>
```

#### With tfsecurity
```shell
$ tfsecurity <dir> --format <format-type>
```

The documentation can be found in Trivy under the [following link.](https://khulnasoft.github.io/trivy/v0.41/docs/configuration/reporting/)

## FAQs

**Does Trivy support junit?**

Yes, Trivy supports different report templates. These can either be set, loaded through a file or by providing a default template such as for JUnit. 

For more information, please [the documentation.](https://khulnasoft.github.io/trivy/v0.41/docs/configuration/reporting/#junit)

**Does Trivy support multiple outputs?**

Currently, the following outputs are supported by Trivy:

* Table
* JSON
* SARIF
* Template
* SBOM

e.g.
```
trivy config --output report.json --format json ./bad_iac/docker
```
This will saver the json report into a `report.json` file.

[Documentation](https://khulnasoft.github.io/trivy/v0.41/docs/configuration/reporting/)

Note that one report can be generated per scan. However, if you require multiple different reports, the same scan would pull the information from the cache to generate a new report format.

**Can Trivy skip files?**

Yes, you can specify that Trivy should skip a directory, using the following flag `--skip-dirs`.

[Documentation](https://khulnasoft.github.io/trivy/v0.41/docs/configuration/others/)

Alternatively, it is possible to skip files, using this flag `--skip-files`.

[Documentation](https://khulnasoft.github.io/trivy/v0.41/docs/configuration/others/#skip-files)

## Feedback

We welcome any feedback if you find features that today are not available with Trivy misconfigration scanning that are available in tfsecurity. 

For further information on scanning terraform with Trivy, do have a look at the [Trivy Terraform Guide](https://khulnasoft.github.io/trivy/latest/tutorials/terraform/scannig/).

[trivy]: https://github.com/khulnasoft/trivy
