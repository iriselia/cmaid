SET( DEFINE
)
SET( INCLUDE
3rdPartyLib
PrivateLib
)
SET( LINK
3rdPartyLib
PrivateLib
)

create_project(DYNAMIC "${DEFINE}" "${INCLUDE}" "${LINK}")
