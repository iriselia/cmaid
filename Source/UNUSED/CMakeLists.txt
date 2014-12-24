SET( DEFINE )
SET( INCLUDE
	ExampleLib
	)
SET( LINK
	ExampleLib
	)

create_project(STATIC "${DEFINE}" "${INCLUDE}" "${LINK}")
