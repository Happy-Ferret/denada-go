package denada

import "fmt"

type Element struct {
	/* Common to all elements */
	Qualifiers    []string
	Name          string
	Description   string
	Modifications map[string]interface{}

	/* For definitions */
	Contents ElementList

	/* For declarations */
	Value interface{}

	definition bool
}

func (e Element) isDefinition() bool {
	return e.definition
}

func (e Element) isDeclaration() bool {
	return !e.definition
}

type ElementList []Element

func (e ElementList) Definition(name string) (Element, error) {
	for _, d := range e {
		if d.isDefinition() && d.Name == name {
			return d, nil
		}
	}
	return Element{}, fmt.Errorf("Unable to find definition for %s")
}

func MakeElementList() ElementList {
	return ElementList{}
}
