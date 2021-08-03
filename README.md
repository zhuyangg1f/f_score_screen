# DSAA R Project Template

This repository contains a skeleton for R projects that all staff should strive to follow for production projects. The goal of this is to create a standardized workflow for projects, so that details irrelevant to the project (ie. how do I deploy something) can be abstracted out of our day-to-day workflows. This standardization will also facilitate collaboration, as all project codebases will look similar structurally, allowing for the same development workflows. 

This template may be subject to change in the future, so make sure you stay up to date :)

# Table of contents

* [Initial set-up](#initial-set-up)
* [Github branching conventions](#github-branching-conventions)
* [`pkg/` sub-directory](#pkg-sub-directory)
    * [Development workflow](#development-workflow)
    * [Contributing to the package](#contributing-to-the-package)
    * [Publishing your package](#publishing-your-package)
    * [Maintaining your package](#maintaining-your-package)
* [`deployments/` sub-directory](#deployments-sub-directory)
    * [Deployment file structure](#deployment-file-structure)
    * [Deployment workflow](#deployment-workflow)
* [Deploying to RStudio Connect](#deploying-to-rstudio-connect)

# Initial set-up

> Code chunks starting with `$` indicate a terminal command; those starting with `>` indicate an R command

1. **[ON GITHUB]** Create a new Github repository, and under "Repository Template", select "LKS-CHART/project-template" (referred to as `project_repo` from here onwards)

2. **[IN RSTUDIO]** Clone your `project_repo` by creating a new RStudio Project from a Version Control source using the repository URL for `project_repo` (eg. git@github.com:LKS-CHART/project_repo.git). 

3. **[IN RSTUDIO]** In your new `project_repo` RStudio project, create a new R package under `pkg/`: `> usethis::create_package(path = "./pkg", fields = list(Package = "yourPackageName"))`. Replace `yourPackageName` with the name of your choosing.  If you are developing a Shiny golem application, you can use `golem::create_golem` in place of `usethis::create_package`.

    + Note: you may get a warning on this step about creating a package inside a project, just ignore it.

    + Note: a new RStudio project named `yourPackageName.Rproj` will be created after this step in the `pkg/` subfolder. This project will be your day-to-day development project.

4.  **[IN RSTUDIO]** Open the new `yourPackageName.Rproj` Rstudio project. Initialize an `renv` project library: `> renv::init()`.
    
At this point, you should have these things set up:

1. A new `project_repo` Github repository for your new project.

2. `project_repo` should contain the skeleton structure from the `deployment_template` repository.

3. `project_repo` should be cloned to your local development environment.

4. `project_repo/pkg` should contain your `yourPackageName` package source, following the standard R package structure (eg. contains a `DESCRIPTION` file, an `R/` sub-directory).

5. `renv` library initialized under `project_repo/pkg`.

# Github branching conventions

The branching requirements for projects may differ slightly depending on the complexity (eg. number of concurrent collaborators) and needs (eg. whether the project contains deployments or not) of the project. The following is a list of branch types that might be suitable for your project:

- `master`/`main`: this branch should exist for all projects, and should reflect the current "ground truth" of a project. This branch typically contains production deployment and their dependencies (eg. project packages), and ideally contains code that has been reviewed and tested (both for low-level functionality, and for higher-level integration behaviour).

- `staging`: this branch should exist for projects containing deployments, and should reflect the current staging deployment(s) for the project. These staging deployments may contain new features, bug fixes, code refactors, etc. and is meant for internal testing. This branch ideally contains code that has been reviewed and tested for low-level functionality. 

- Release branches (eg. `v1.0`): these branches might be helpful for larger projects, particularly those with a sprint structure or a phased approach. Specifically, this branch should contain source code changes (eg. changes to application modules or project packages) for a specific sprint/phase/release, and serves as a base to merge new feature branches. This branch is similar to the `staging` branch, but it's helpful to distinguish source code changes from deployment specification changes, as it allows you to bypass the `staging` branch and merge directly to `master` (note: you may need to keep `staging` up to date with `master` via `git rebase` or `git merge`). For smaller projects and maintenance tasks, these branches may not be necessary, and you can instead merge source code changes directly to `master`; however, if your project contains deployments, you should still test the changes by upgrading the `staging` deployment before upgrading the production/`master`/`main` deployment.

- Feature/task branches (eg. `b/bug-fix`, `f/add-feature`): these branches are the day-to-day development branches. These branches should ideally map one-to-one to project tasks. These branches are typically created off of the working base branch of your project. For source code changes, this could be a release branch or `master`/`main`; for deployment specification changes, this should be the `staging` branch. It's good practice to use the suffix `f/` for feature branches and `b/` for bug fix branches.

# `pkg/` sub-directory

The `pkg/` sub-folder contains the project package. This means that all project-specific functions, APIs, app modules, etc. should live here. This package contains the guts of your project, and this section provides some tips on how to optimally use this project structure.

## Development workflow

Your day-to-day development will mostly pertain to files within the `pkg/` sub-directory using the `yourPackageName` RStudio project. As much as possible, try to develop code within the `pkg/` sub-directory and `yourPackageName` RStudio project; you should not have any new function definitions or complicated computations/data processing outside of this sub-directory. This also means that you should try to minimize the lines of code within each deployment under `deployments/`, as code living there will likely not be tested. 

For example, a Shiny golem application deployment `app.R` file may look something like this:

```{r}
# deployments/app/awesome_app.R

# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file

yourPackageName::run_app(some_runtime_parameter)

```

For a Plumber API, this may look something like this: 

```{r}
# deployments/api/awesome_api.R

library(plumber)

#* @apiTitle A really awesome Plumber API

#* Get model predictions
#* @param input_data 
#* @post /predict
function(input_data) {
    yourPackageName::predict(input_data)
}

```

The functions `run_app` and `predict` will be defined within your project package under `pkg/R/run_app.R` `pkg/R/predict.R`, with associated tests under `pkg/tests`.

RMarkdown documents may contain some code additional code, but try to incorporate any complicated calculations or methods as individual functions within your package, and then calling those functions inside your RMarkdown file. For pipelines written in RMarkdown, you can use the `drake` package (see example [here](https://github.com/LKS-CHART/drakeExample)).

## Contributing to the package

- Develop new features and bug fixes in a feature branch, following the [Github branching conventions](#github-branching-conventions).
- Include the relevant ClickUp ID for the feature you are working on in each
commit message. ClickUp can pickup on these IDs to manually update task
progress, and this helps us associate each commit to a task.
- Please include new test cases when contributing new code.
- For updates to the `pkg/` requiring a version upgrade, be sure to update `DESCRIPTION` and `NEWS.md`, and tag the new release on Github more on this in [this section](#maintaining-your-project-package))
- When your feature is ready for review, create a PR into the working base branch for your project - this could be a release branch (eg. `v1.0`), the staging branch (for deployments), or the master branch (for smaller updates/hotfixes). Tag your project buddy for review, and please complete the PR template when opening a new PR.
- When your PR passes review, you may merge the branch and delete the feature branch to reduce clutter. 
- For `pkg/` updates involving an upgrade in version number, RSPM will periodically poll Github for new tags, and add new versions of packages when a new tag is detected.


## Publishing your package

Once you have your project repository set up and your project package is created, you will need to submit a request to have your project package served on RStudio Package Manager (RSPM). Going through this process will allow your package to be installable from our development (eg. laptops) and production environments (eg. Veneto). This will then allow you to install and use your package as a dependency in your deployments (eg. allowing you to deploy a Shiny application that calls `yourPackageName::run_app()`). 

To have your package served on RSPM:

1. Ensure that your R package can be installed using `remotes::install_github("LKS-CHART/project_repo", subdir = "pkg")`

2. Ensure that any dependencies that your package has is also available on RSPM. All CRAN packages should be available, but this may not be the case for Github packages. If a Github dependency is not available, you will also need to submit a request for that package to be added to RSPM.

3. [Complete the Click-up request form](https://forms.clickup.com/f/27kem-7665/U3047DXL6TGY5CDVEI) and send Colin & David an email/Slack DM. 

4. Colin/David will add your package to RSPM, and all **tagged releases** of your package will be automatically synced to RSPM.

## Maintaining your package

After your package has been added to RSPM, any updates to your package will need to be **versioned** and **tagged**. This is crucial, as RSPM will only sync your package if the it detects a new Github tag. This has several implications:

1. As you develop your project, try to plan releases with your Project Manager and project team. You should work together to determine what are the important features to work on, and group these into releases. 

2. Once you have identified a set of tasks to complete for your next release, work on these tasks in separate feature branches, and merge these back into `staging` or a `release-version` branch when the task is completed. 

3. Make sure to increment your package DESCRIPTION version number ([how to choose a version number?](https://r-pkgs.org/release.html#release-version))

4. Once you have completed all tasks for a release and incremented your version number, you can merge the `release-version` branch back to the `master` branch, and [create a tagged release](https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/managing-releases-in-a-repository). **Note: your tag version name must match your DESCRIPTION version number (eg. if your version number is 1.0.0, your tag should be named 1.0.0)**

5. All tagged releases will be synced and installable from RSPM using `install.packages("yourPackageName", repos = "http://172.27.21.214:4242/prod/latest")`

# `deployments/` sub-directory 

For R deployments (eg. RMarkdown documents, Shiny applications, Plumber APIs), deployment dependencies should be managed by your project package. As such, your deployment scripts should contain your project package as a dependency, while other required packages should be imported via helper functions within the project package (eg. if you are using the `config` package, you can create a `read_config` helper function that imports `config`). This allows you to put as much code into the project package as possible, where it can be properly tested and documented. Aside from the project package, you may find the `rsconnect` and `devtools` packages helpful for package and deployment maintenance.

## Deployments file structure

All deployments should be placed under the `deployments/` sub-folder. Each deployment should be placed in its own folder, similar to what is illustrated below:

```
project_repo/
├── README.md
├── .gitignore
│   ├── deployments/
|       ├── cool_api/
|       ├── awesome_api/
|       ├── fancy_app/
|       ├── slick_app/
|       ├── slickity_report/
|       ├── sleek_report/
│   └── pkg/
|       ├── ...
└── ...
      
```

Within each deployment's folder, it may look something like this:

```
...
│   ├── deployments/
|       ├── deployments.Rproj
|       ├── cool_api/
|           ├── plumber.R
|           ├── manifest.json
|           ├── renv/
|           ├── renv.lock
|           ├── .Rprofile
|       ├── fancy_app/
|           ├── app.R
|           ├── manifest.json
|           ├── renv/
|           ├── renv.lock
|           ├── .Rprofile
|       ├── slickity_report/
|           ├── slickity_report.Rmd
|           ├── manifest.json
|           ├── renv/
|           ├── renv.lock
|           ├── .Rprofile
...
```

If you are not using Git-backed deployment, you will not have an associated `manifest.json` for each deployment. Push button deployment can be used from RStudio, and it will create the necessary deployment configurations in a `rsconnect/` sub-folder. 

## Using `renv`

When using `renv` to manage dependencies for your deployments, it's sometimes desirable to have separate `renv` libraries for each deployment, as this will allow you to have separate versions of packages (eg. v1.0 on production, v1.1 on staging).

To set-up deployment-specific `renv` libraries:

1. Use `renv::init(project = "fancy_app/")` to initialize an `renv` library under `deployments/fancy_app`
2. Whenever you want to manage this deployment, use `renv::activate(project = "fancy_app/")` to activate this deployment's `renv` library.
3. After activation, all subsequent `renv` function calls (eg. `renv::install`, `renv::snapshot`, `renv::restore`) will now default to this library.

## Deployment workflow

If your deployment depends on your project package, you must publish your package on RStudio Package Manager (follow instructions in the previous section) so that deployment dependencies are installable. After your package is version/tagged and published to RSPM, install the package from RSPM using `renv::install("yourPackageName")`; your deployments should work in an isolated environment, provided that `yourPackageName` is installed. 

### Git-backed deployment

This section summarises the typical workflow for maintaining Git-backed deployments for RStudio Connect. For more information about Git-backed deployment for RStudio Connect, (please see [documentation in Clickup](https://app.clickup.com/2346452/v/dc/27kem-5880/27kem-2821)).

1. Open the `deployments.Rproj` project. Create a new branch from `staging/`.

2. Activate the deployment `renv` environment using `renv::activate(project = "fancy_app/")` (swap `"fancy_app/"` with your specific deployment folder name).

3. Verify that the updated package is pushed to RSPM by installing it using `renv::install(packageName@new_version_num)`.
    - Note: you must add RSPM to the list of `renv` repositories, [see here](#using-renv) for more details

4. Verify that the deployment functions as expected in this environment, in case any development  dependencies may have been missed in the project package `DESCRIPTION` imports.

5. Snapshot the new dependencies: `renv::snapshot()`.

6. Update your deployment `manifest.json`: `rsconnect::writeManifest(appDir = "fancy_app/", appFiles = "app.R")`.

7. Submit a PR to the `staging` branch. After PR approval, merge this branch and the affected staging deployments will be updated and ready for user testing/silent deployment.

8. If user testing/silent deployment passes, then submit a PR from `staging` to `master`. Merging this PR will trigger updates to the affected production deployments.
