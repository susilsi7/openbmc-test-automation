*** Settings ***
Documentation    Test BMC Manager functionality.
Resource         ../../lib/resource.robot
Resource         ../../lib/bmc_redfish_resource.robot
Resource         ../../lib/common_utils.robot
Resource         ../../lib/openbmc_ffdc.robot
Resource         ../../lib/boot_utils.robot
Resource         ../../lib/open_power_utils.robot

Test Setup       Test Setup Execution
Test Teardown    Test Teardown Execution

*** Test Cases ***

Verify Redfish BMC Firmware Version
    [Documentation]  Get firmware version from BMC manager.
    [Tags]  Verify_Redfish_BMC_Firmware_Version

    Redfish.Login
    ${resp}=  Redfish.Get  /redfish/v1/Managers/bmc
    Should Be Equal As Strings  ${resp.status}  ${HTTP_OK}
    ${bmc_version}=  Get BMC Version
    Should Be Equal As Strings
    ...  ${resp.dict["FirmwareVersion"]}  ${bmc_version.strip('"')}


Verify Redfish BMC Manager Properties
    [Documentation]  Verify BMC managers resource properties.
    [Tags]  Verify_Redfish_BMC_Manager_Properties

    Redfish.Login
    ${resp}=  Redfish.Get  /redfish/v1/Managers/bmc
    Should Be Equal As Strings  ${resp.status}  ${HTTP_OK}
    # Example:
    #  "Description": "Baseboard Management Controller"
    #  "Id": "bmc"
    #  "Model": "OpenBmc",
    #  "Name": "OpenBmc Manager",
    #  "UUID": "xxxxxxxx-xxx-xxx-xxx-xxxxxxxxxxxx"
    #  "PowerState": "On"

    Should Be Equal As Strings
    ...  ${resp.dict["Description"]}  Baseboard Management Controller
    Should Be Equal As Strings  ${resp.dict["Id"]}  bmc
    Should Be Equal As Strings  ${resp.dict["Model"]}  OpenBmc
    Should Be Equal As Strings  ${resp.dict["Name"]}  OpenBmc Manager
    Should Not Be Empty  ${resp.dict["UUID"]}
    Should Be Equal As Strings  ${resp.dict["PowerState"]}  On


Redfish BMC Manager GracefulRestart When Host Off
    [Documentation]  BMC graceful restart when host is powered off.
    [Tags]  Redfish_BMC_Manager_GracefulRestart_When_Host_Off

    # "Actions": {
    # "#Manager.Reset": {
    #  "ResetType@Redfish.AllowableValues": [
    #    "GracefulRestart"
    #  ],
    #  "target": "/redfish/v1/Managers/bmc/Actions/Manager.Reset"
    # }

    Redfish OBMC Reboot (off)


Redfish BMC Manager GracefulRestart When Host Booted
    [Documentation]  BMC graceful restart when host is running.
    [Tags]  Redfish_BMC_Manager_GracefulRestart_When_Host_Booted

    Redfish OBMC Reboot (run)

    # TODO: Replace OCC state check with redfish property when available.
    Verify OCC State


*** Keywords ***

Test Setup Execution
    [Documentation]  Do test case setup tasks.

    redfish.Login


Test Teardown Execution
    [Documentation]  Do the post test teardown.

    FFDC On Test Case Fail
    redfish.Logout
