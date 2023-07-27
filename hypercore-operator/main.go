package main

import (
	"context"
	"fmt"
	"time"

	"github.com/operator-framework/operator-sdk/pkg/sdk"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

// HypercoreServerReconciler reconciles a HypercoreServer object
type HypercoreServerReconciler struct {
	client.Client
	Log    ctrl.Log
	Scheme *runtime.Scheme
}

// Reconcile handles the main logic for the HypercoreServer Operator.
func (r *HypercoreServerReconciler) Reconcile(req ctrl.Request) (ctrl.Result, error) {
	ctx := context.Background()
	log := r.Log.WithValues("hypercoreserver", req.NamespacedName)

	// Fetch the HypercoreServer custom resource.
	server := &examplecomv1.HypercoreServer{}
	if err := r.Get(ctx, req.NamespacedName, server); err != nil {
		log.Error(err, "unable to fetch HypercoreServer")
		return ctrl.Result{}, client.IgnoreNotFound(err)
	}

	// Create the Pod for the HypercoreServer.
	pod := &corev1.Pod{
		ObjectMeta: metav1.ObjectMeta{
			Name:      server.Name + "-pod",
			Namespace: server.Namespace,
		},
		Spec: corev1.PodSpec{
			Containers: []corev1.Container{
				{
					Name:  "hypercore-server",
					Image: "your-image-repo/hypercore-server:latest",
					Ports: []corev1.ContainerPort{
						{
							Name:          "webhook",
							Protocol:      corev1.ProtocolTCP,
							ContainerPort: server.Spec.WebhookPort,
						},
					},
				},
			},
		},
	}

	// Set the owner reference to ensure proper garbage collection.
	if err := ctrl.SetControllerReference(server, pod, r.Scheme); err != nil {
		return ctrl.Result{}, err
	}

	// Create or Update the Pod.
	if err := r.CreateOrUpdate(ctx, pod); err != nil {
		log.Error(err, "unable to create Pod for HypercoreServer", "pod", pod)
		return ctrl.Result{}, err
	}

	// Update the status with the name of the Pod running the Hypercore server.
	server.Status.Nodes = pod.Name
	if err := r.Status().Update(ctx, server); err != nil {
		log.Error(err, "unable to update HypercoreServer status")
		return ctrl.Result{}, err
	}

	return ctrl.Result{}, nil
}

func main() {
	if err := sdk.Watch(
		&examplecomv1.HypercoreServer{},
		&HypercoreServerReconciler{},
		sdk.WithWatchNamespace(sdk.NamespaceAll),
	); err != nil {
		fmt.Printf("error occurred: %v", err)
		os.Exit(1)
	}
}
