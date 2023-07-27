#!/bin/bash

# Replace these variables with your desired values
DOMAIN="example.com"
REPO_PATH="github.com/yourusername/hypercore-operator"
CRD_GROUP="example"
CRD_VERSION="v1"
CRD_KIND="HypercoreServer"
WEBHOOK_PORT="3000"
OPERATOR_IMAGE="your-operator-image:latest"

# Create the Operator project directory
mkdir hypercore-operator
cd hypercore-operator

# Initialize the Operator project
go mod init $REPO_PATH

# Create the API types directory
mkdir -p api/v1

# Create the API types definition file
cat <<EOF > api/v1/hypercoreserver_types.go
package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +kubebuilder:object:root=true

type HypercoreServer struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`
	Spec              HypercoreServerSpec   `json:"spec,omitempty"`
	Status            HypercoreServerStatus `json:"status,omitempty"`
}

type HypercoreServerSpec struct {
	// Add your HypercoreServer spec fields here
}

type HypercoreServerStatus struct {
	// Add your HypercoreServer status fields here
}

// +kubebuilder:object:root=true

type HypercoreServerList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []HypercoreServer `json:"items"`
}
EOF

# Create the main API groupversion_info.go file
cat <<EOF > api/v1/groupversion_info.go
package v1

import (
	"k8s.io/apimachinery/pkg/runtime/schema"
	"sigs.k8s.io/controller-runtime/pkg/scheme"
)

var (
	// SchemeGroupVersion is the group version used to register these objects
	SchemeGroupVersion = schema.GroupVersion{Group: "$CRD_GROUP.$DOMAIN", Version: "$CRD_VERSION"}

	// SchemeBuilder points to a list of functions added to Scheme.
	SchemeBuilder = &scheme.Builder{GroupVersion: SchemeGroupVersion}
)

func init() {
	// Register the types with the Scheme so the components can map objects to GroupVersionKinds and back
	if err := SchemeBuilder.AddToScheme(scheme.Scheme); err != nil {
		panic(err)
	}
}
EOF

# Create the controller directory
mkdir controllers

# Create the controller file with placeholder code
cat <<EOF > controllers/hypercoreserver_controller.go
package controllers

import (
	"context"
	"fmt"
	"time"

	"github.com/go-logr/logr"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
	"sigs.k8s.io/controller-runtime/pkg/reconcile"

	corev1 "k8s.io/api/core/v1"
)

// Your actual reconciliation logic goes here
// ...

EOF

# Create the webhook directory
mkdir webhook
cd webhook

# Create package.json with express and body-parser dependencies
echo '{
  "name": "hypercore-webhook",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.17.1",
    "body-parser": "^1.19.0"
  }
}' > package.json

# Install dependencies
npm install

# Create webhook server code
cat <<EOF > server.js
const express = require('express');
const bodyParser = require('body-parser');
const app = express();
app.use(bodyParser.json());

app.post('/hypercore/:action', async (req, res) => {
  const action = req.params.action;
  const params = req.body;
  // Your webhook logic for handling Hypercore actions
  // ...

  res.json({ status: 'ok' });
});

const WEBHOOK_PORT = ${WEBHOOK_PORT};
app.listen(WEBHOOK_PORT, () => {
  console.log(\`Hypercore webhook server listening on port \${WEBHOOK_PORT}\`);
});
EOF

cd ..

# Create Dockerfile for building the Operator image
cat <<EOF > Dockerfile
FROM scratch
# Your actual Dockerfile configuration goes here
# ...

EOF

# Create the CRD YAML
mkdir -p config/crd/bases
cat <<EOF > config/crd/bases/$CRD_GROUP_$CRD_VERSION_$CRD_KIND.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: $CRD_GROUP.$CRD_VERSION.$CRD_KIND
spec:
  group: $CRD_GROUP.$DOMAIN
  versions:
    - name: $CRD_VERSION
      served: true
      storage: true
  scope: Namespaced
  names:
    plural: hypercoreservers
    singular: hypercoreserver
    kind: $CRD_KIND
EOF

# Create main.go for the Operator entry point
cat <<EOF > main.go
package main

import (
	"flag"
	"os"

	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log/zap"
)

var (
	metricsAddr         = flag.String("metrics-addr", ":8080", "The address the metric endpoint binds to.")
	enableLeaderElection = flag.Bool("enable-leader-election", false, "Enable leader election for controller manager.")
)

func main() {
	flag.Parse()

	ctrl.SetLogger(zap.New(zap.UseDevMode(true)))

	mgr, err := ctrl.NewManager(ctrl.GetConfigOrDie(), ctrl.Options{
		Scheme:             scheme,
		MetricsBindAddress: *metricsAddr,
		LeaderElection:     *enableLeaderElection,
		LeaderElectionID:   "$DOMAIN/$REPO_PATH",
	})
	if err != nil {
		setupLog.Error(err, "unable to start manager")
		os.Exit(1)
	}

	if err = (&controllers.HypercoreServerReconciler{
		Client: mgr.GetClient(),
		Log:    ctrl.Log.WithName("controllers").WithName("HypercoreServer"),
		Scheme: mgr.GetScheme(),
	}).SetupWithManager(mgr); err != nil {
		setupLog.Error(err, "unable to create controller", "controller", "HypercoreServer")
		os.Exit(1)
	}
	// +kubebuilder:scaffold:builder

	setupLog.Info("starting manager")
	if err := mgr.Start(ctrl.SetupSignalHandler()); err != nil {
		setupLog.Error(err, "problem running manager")
		os.Exit(1)
	}
}
EOF

# Generate boilerplate code
go mod tidy
operator-sdk generate k8s

echo "Operator project generated successfully!"
