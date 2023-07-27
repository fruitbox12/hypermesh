package v1

import (
	"k8s.io/apimachinery/pkg/runtime/schema"
	"sigs.k8s.io/controller-runtime/pkg/scheme"
)

var (
	// SchemeGroupVersion is the group version used to register these objects
	SchemeGroupVersion = schema.GroupVersion{Group: "example.example.com", Version: "v1"}

	// SchemeBuilder points to a list of functions added to Scheme.
	SchemeBuilder = &scheme.Builder{GroupVersion: SchemeGroupVersion}
)

func init() {
	// Register the types with the Scheme so the components can map objects to GroupVersionKinds and back
	if err := SchemeBuilder.AddToScheme(scheme.Scheme); err != nil {
		panic(err)
	}
}
