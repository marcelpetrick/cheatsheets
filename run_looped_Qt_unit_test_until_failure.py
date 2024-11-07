import subprocess

run_count = 0

while True:
    run_count += 1
    print(f"##### run {run_count} #####")

    # Run the program and capture the output
    result = subprocess.run(["./tst_maintenanceprogram"], capture_output=True, text=True)

    # Combine stdout and stderr for easier processing
    output = result.stdout + result.stderr
    print(output)

    # Check each line in the output
    for line in output.splitlines():
        if line.startswith("Totals"):
            # Check if "0 failed" is in the Totals line
            if "0 failed" in line:
                print("Run succeeded. No failures detected.")
                break
            else:
                print("Failure detected in Totals line. Aborting script.")
                exit(1)
