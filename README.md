This repository is designed for conducting performance tests using Apache JMeter. The project includes a Bitbucket pipeline configuration for running tests automatically and a Dockerfile for building a JMeter environment with additional plugins. Below, you'll find instructions on how to get strtaed with theproject , adding new JMeter tests, running tests on Bitbucket, and developing locally.

### Execute Existing Test on Bitbucket

1. Navigate to the **Pipelines** section of the project.

2. Click on **Run Pipeline**.

3. Select the target **branch** (use `main` for stable, or choose a feature or release branch).

4. Choose the desired **Pipeline** to run (`run_jmeter_load_test` for the initial trial).

5. Fill out or select the following **variables**:

   - **JIRA:** Enter the JIRA ticket ID. This is the Performance Test task associated with running the test. The results will be attached as a new Jira task to this parent ticket. Leave it empty, if you don't need it.
   
   - **FIX_VERSION:** Specify the value of the Fix Versions field in Jira. This should pre-exist in Jira and is used to track test execution for releases. Optional, Leave it empty, if you don't need it.
   
   - **THREADS:** Set the number of concurrent users (threads).
   
   - **THREAD_LIFETIME:** Define the test duration in seconds.

   - **TEST_NAME:** Set your jmeter script name from jmeter-scripts folder. Use `hitting-dummy-endpoint.jmx` to test your pipeline.
   
   - **DATA_FILE:** If your JMeter test requires a CSV file with data, specify the file here.
   
   - **JIRA_SERVICE_TOKEN:** Enter your personal JIRA token. You can create one by visiting [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens) and logging in with your Microsoft account. Note: Store IRA_SERVICE_EMAIL, JIRA_SERVICE_TOKEN, JIRA_URL as Bitbucket variable and make it secure, so they won't be exposed.
   
   - **JIRA_SERVICE_EMAIL:** Provide your email address associated with Jira account.
   Note: Store IRA_SERVICE_EMAIL, JIRA_SERVICE_TOKEN, JIRA_URL as Bitbucket variable and make it secure, so they won't be exposed.

6. Click on **Run** and wait until all steps are completed.

7. Once the test is finished, the results will be attached to the newly created Jira ticket under the specified ID. Unzip the HTML report and review the graphs. If, for any reason, the results are not attached to Jira, they will still be available as build artifacts.

### Adding a New JMeter Test (Local Development)

#### Pre-requisite Technologies

- [JAVA] version 8 or higher

- [JMeter] - the supported version provided as part of the project; the current version is 6.5.2 in the apache-jmeter-5.6.2 directory

#### Setup Instructions

1. **Clone the Repository onto Your Local Machine:**

```bash
git clone https://github.com/DmitriyMazur/jmeter-bitbucket.git
```

2. **Create/Checkout a New Branch:**

```bash
git checkout -b feature/jira-test-name
```

   
3. **Start JMeter UI:**
   
   - Run `apache-jmeter-5.6.2/bin/jmeter.bat` (Windows) or `apache-jmeter-5.6.2/bin/jmeter.sh` (Mac).

4. **Create a New Script:**
   
   - Save it under `/jmeter-scripts`. Check existing scripts for passing parameters. If your test requires something different, create a new pipeline.

5. **Update Properties File:**
   
   - Navigate to the `/config` folder and find `<env>.properties`. Open this file and make necessary updates. Example:
   
     ```properties
     HOST=example.com
     ```

6. **Add New Files to the Index:**

```bash
git add .
```

7. **Stage Your Changes:**

```bash
git commit -m "JIRA ID Add or enhance JMeter tests for feature XYZ"
```

8. **Push Changes to the Repository:**

```bash
git push origin feature/jira-test-name
```

9. **Run Your Test on the Pipeline:**

   - Run your test with a single user and low duration on the pipeline under your feature branch to ensure everything works before executing a full-scale test.


### Adding New JMeter Plugins

If your test requires plugins not included in the jmeter docker image, update the Docker image and point to your docker image repo:

1. Update Dockerfile:
   
   - Add the plugin JAR URLs in the Dockerfile using the `RUN wget -O` command (check how it's done for other plugins)
   
   - Ensure the paths are correct for the JMeter version.
   
2. Change bitbucket-pipelines.yml to point to your docker image (current `image: dmitrymazur/jmeter:5.6.2`)








