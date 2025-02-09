/*
SUMMARY: Move one or more subscriptions to a new management group.
DESCRIPTION:
  Move one or more subscriptions to a new management group.
  
  Once the subscription(s) are moved, Azure Policies assigned to the new management group or it's parent management group(s) will begin to govern the subscription(s).

AUTHOR/S: SenthuranSivananthan
VERSION: 1.0.0
*/
targetScope = 'managementGroup'

@description('Array of Subscription Ids that should be moved to the new management group.')
param parSubscriptionIds array = []

@description('Target management group for the subscription.  This management group must exist.')
param parTargetManagementGroupId string

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaid = '3dfa9e81-f0cf-4b25-858e-167937fd380b'

resource resSubscriptionPlacement 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' = [for subscriptionId in parSubscriptionIds: {
  scope: tenant()
  name: '${parTargetManagementGroupId}/${subscriptionId}'
}]

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../CRML/customerUsageAttribution/cuaIdManagementGroup.bicep' = if (!parTelemetryOptOut) {
  name: 'pid-${varCuaid}-${uniqueString(deployment().location)}'
  params: {}
}
