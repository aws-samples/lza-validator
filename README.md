# LZA-Validator

LZA-Validator is a tool that validates the configurations of [Landing Zone Accelerator on AWS](https://aws.amazon.com/solutions/implementations/landing-zone-accelerator-on-aws/). It is in the format of a docker image which is created from the source code of [landing-zone-accelerator-on-aws repository](https://github.com/awslabs/landing-zone-accelerator-on-aws).

## Build

Run `bash build.sh` to build the tool. By default, it only builds for the latest [release of LZA](https://github.com/awslabs/landing-zone-accelerator-on-aws/releases). Update `n` in the [build.sh](./build.sh) script to include more releases if needed.

```
➜  lza-validator git:(main) ✗ bash build.sh
Cloning into 'landing-zone-accelerator-on-aws'...
remote: Enumerating objects: 27375, done.
remote: Counting objects: 100% (12847/12847), done.
remote: Compressing objects: 100% (3849/3849), done.
remote: Total 27375 (delta 9437), reused 11631 (delta 8550), pack-reused 14528
Receiving objects: 100% (27375/27375), 25.03 MiB | 5.87 MiB/s, done.
Resolving deltas: 100% (20782/20782), done.
Already on 'main'
Your branch is up to date with 'origin/main'.
Already up to date.
HEAD is now at 21d70cee release/v1.4.1
[+] Building 521.3s (12/12) FINISHED                                                                                                    ...
 => => writing image sha256:4bb7a9c573418a5c0c84cffcf10c45725aad933d05dd5f345bdf05f4339b9116                                                                0.0s
 => => naming to docker.io/library/lza-validator:v1.4.1                                                                                                     0.0s

```

Once the build is completed. You should be able to see the docker images.

```
docker images | grep lza-validator
```

_Use [finch](https://github.com/runfinch/finch) if you don't have Docker Desktop license._

## Usage

```
docker run --rm --volume <path_to_lza_configuration_folder>:/lza/config lza-validator:<lza_release>
```

For example:

```
➜  ~ docker run --rm --volume ~/aws-accelerator-config:/lza/config lza-validator:v1.4.1

yarn run v1.22.19
$ ts-node $PWD/packages/@aws-accelerator/accelerator/lib/config-validator.ts /lza/config/
2023-06-16 04:35:50.257 | info | config-validator | Config source directory -  /lza/config/
2023-06-16 04:35:50.352 | info | accounts-config-validator | accounts-config.yaml file validation started
2023-06-16 04:35:50.354 | info | customizations-config-validator | customizations-config.yaml file validation started
2023-06-16 04:35:50.366 | info | global-config-validator | global-config.yaml file validation started
2023-06-16 04:35:50.375 | info | iam-config-validator | iam-config.yaml file validation started
2023-06-16 04:35:50.383 | info | network-config-validator | network-config.yaml file validation started
2023-06-16 04:35:50.390 | info | organization-config-validator | organization-config.yaml file validation started
2023-06-16 04:35:50.416 | info | security-config-validator | security-config.yaml file validation started
2023-06-16 04:35:50.428 | info | config-validator | Config file validation successful.
(node:28) NOTE: We are formalizing our plans to enter AWS SDK for JavaScript (v2) into maintenance mode in 2023.

Please migrate your code to use AWS SDK for JavaScript (v3).
For more information, check the migration guide at https://a.co/7PzMCcy
(Use `node --trace-warnings ...` to show where the warning was created)
Done in 6.42s.
```

**Tip**: Write a bash script wrapper to simplify the usage - Create an **executable** file `/usr/local/bin/lza-validator` with following contents.

```
#!/bin/bash

docker run --rm --volume $2:/lza/config lza-validator:$1
```

Now you can validate the configurations with the syntax: `lza-validator <lza_release> <path_to_lza_configuration_folder>`.

For example:

```
lza-validator v1.4.1 ~/aws-accelerator-config
```

## Development

- [lza-validator.sh](./lza-validator.sh): The entrypoint for the docker image.
- [Dockerfile](./Dockerfile): Dockerfile for LZA-Validator docker image.
- [build.sh](./build.sh): Run this script to start build images.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
