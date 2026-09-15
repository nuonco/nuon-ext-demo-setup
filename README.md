# Nuon Demo Setup Extension

This extension creates a demo organization, syncs example applications, creates an install for each application, and provisions each install stack with the published AWS or GCP Terraform module.

## Prerequisites

- Nuon CLI 0.19 or later, authenticated with `nuon auth login`
- Terraform 1.9 or later
- `jq`, `curl`, and `git`
- AWS credentials, optionally selected with `AWS_PROFILE`
- `gcloud` or `GOOGLE_PROJECT` when provisioning GCP

Install the extension:

```sh
nuon extensions install nuonco/nuon-ext-demo-setup
```

## Usage

Create an organization and provision the default AWS and GCP example applications:

```sh
AWS_PROFILE=acme-admin GOOGLE_PROJECT=acme-demo \
  nuon demo-setup setup "Acme Demo"
```

If no GCP project is configured, the GCP application is skipped. The command prints the organization ID and state directory when it finishes.

Destroy the Terraform-managed resources and installs:

```sh
AWS_PROFILE=acme-admin \
  nuon demo-setup teardown <org-id>
```

Teardown destroys the stacks before deleting their installs because the stack provider needs the install while destroying resources. The organization remains and can be removed from the admin dashboard.

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `DEMO_APPS` | `httpbin gcp-httpbin` | Space-separated example application directories |
| `DEMO_AWS_REGION` | `us-west-2` | AWS region |
| `DEMO_GCP_REGION` | `us-central1` | GCP region |
| `DEMO_STATE_DIR` | `~/.nuon-demo` | Terraform state and log directory |
| `DEMO_STACK_WAIT_SECS` | `600` | Maximum wait for stack service-account readiness |
| `NUON_STACK_API_URL` | Runner group API URL | Override for the stack provider API |
| `NUON_BIN` | `nuon` | Nuon CLI binary |
| `GOOGLE_PROJECT` | Current `gcloud` project | GCP project |

Set `DEMO_APPS=httpbin` for AWS only or `DEMO_APPS=gcp-httpbin` for GCP only.

## How it works

1. The extension creates an organization and passes `--no-select` so the current CLI context is unchanged.
2. It syncs each example configuration and creates its install without selecting either resource.
3. It waits until the install workflow has generated the first stack version and stack service account.
4. It creates a temporary stack service-account token. The token is passed only to the Terraform process and is not written to disk.
5. Terraform reads the stack configuration from the runner API and applies the matching registry module. AWS configurations can include a vendor VPC CloudFormation template; the AWS module deploys that template before building the remaining stack.
6. The stack provider reports completion to the control plane so the install workflow can continue. Terraform files, state, and logs remain under `DEMO_STATE_DIR` for teardown and troubleshooting.

## Local development

Install the extension from a working copy:

```sh
~/bin/nuon-dev -f ~/.seed.yml extensions install \
  ~/Repos.nosync/nuonco/nuon-ext-demo-setup
```

The local runner API is normally available on port 8083. Override the provider URL when testing through the local CLI:

```sh
NUON_BIN=~/bin/nuon-dev \
NUON_STACK_API_URL=http://localhost:8083 \
AWS_PROFILE=acme-admin \
DEMO_APPS=httpbin \
~/bin/nuon-dev -f ~/.seed.yml demo-setup setup "Acme Local Demo"
```

Use the same `NUON_BIN`, `NUON_STACK_API_URL`, and cloud credential variables for teardown.
