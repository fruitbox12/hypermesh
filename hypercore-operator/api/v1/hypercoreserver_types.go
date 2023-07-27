package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +kubebuilder:object:root=true

type HypercoreServer struct {
	metav1.TypeMeta   
	metav1.ObjectMeta 
	Spec              HypercoreServerSpec   
	Status            HypercoreServerStatus 
}

type HypercoreServerSpec struct {
	// Add your HypercoreServer spec fields here
}

type HypercoreServerStatus struct {
	// Add your HypercoreServer status fields here
}

// +kubebuilder:object:root=true

type HypercoreServerList struct {
	metav1.TypeMeta 
	metav1.ListMeta 
	Items           []HypercoreServer 
}
