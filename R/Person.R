#' Person 
#'
#' A person (alive, dead, undead, or fictional). 
#'
#'
#' @param id identifier for the object (URI)
#' @param worksFor (Organization type.) Organizations that the person works for.
#' @param workLocation (Place or ContactPoint type.) A contact location for a person's place of work.
#' @param weight (QuantitativeValue or QuantitativeValue type.) The weight of the product or person.
#' @param vatID (Text or Text type.) The Value-added Tax ID of the organization or person.
#' @param telephone (Text or Text or Text or Text type.) The telephone number.
#' @param taxID (Text or Text type.) The Tax / Fiscal ID of the organization or person, e.g. the TIN in the US or the CIF/NIF in Spain.
#' @param spouse (Person type.) The person's spouse.
#' @param sponsor (Person or Organization or Person or Organization or Person or Organization or Person or Organization type.) A person or organization that supports a thing through a pledge, promise, or financial contribution. e.g. a sponsor of a Medical Study or a corporate sponsor of an event.
#' @param siblings (Person type.) A sibling of the person.
#' @param sibling (Person type.) A sibling of the person.
#' @param seeks (Demand or Demand type.) A pointer to products or services sought by the organization or person (demand).
#' @param relatedTo (Person type.) The most generic familial relation.
#' @param publishingPrinciples (URL or CreativeWork or URL or CreativeWork or URL or CreativeWork type.) The publishingPrinciples property indicates (typically via [[URL]]) a document describing the editorial principles of an [[Organization]] (or individual e.g. a [[Person]] writing a blog) that relate to their activities as a publisher, e.g. ethics or diversity policies. When applied to a [[CreativeWork]] (e.g. [[NewsArticle]]) the principles are those of the party primarily responsible for the creation of the [[CreativeWork]].While such policies are most typically expressed in natural language, sometimes related information (e.g. indicating a [[funder]]) can be expressed using schema.org terminology.
#' @param performerIn (Event type.) Event that this person is a performer or participant in.
#' @param parents (Person type.) A parents of the person.
#' @param parent (Person type.) A parent of this person.
#' @param owns (Product or OwnershipInfo or Product or OwnershipInfo type.) Products owned by the organization or person.
#' @param netWorth (PriceSpecification or MonetaryAmount type.) The total financial value of the person as calculated by subtracting assets from liabilities.
#' @param nationality (Country type.) Nationality of the person.
#' @param naics (Text or Text type.) The North American Industry Classification System (NAICS) code for a particular organization or business person.
#' @param memberOf (ProgramMembership or Organization or ProgramMembership or Organization type.) An Organization (or ProgramMembership) to which this Person or Organization belongs.
#' @param makesOffer (Offer or Offer type.) A pointer to products or services offered by the organization or person.
#' @param knows (Person type.) The most generic bi-directional social/work relation.
#' @param jobTitle (Text type.) The job title of the person (for example, Financial Manager).
#' @param isicV4 (Text or Text or Text type.) The International Standard of Industrial Classification of All Economic Activities (ISIC), Revision 4 code for a particular organization, business person, or place.
#' @param honorificSuffix (Text type.) An honorific suffix preceding a Person's name such as M.D. /PhD/MSCSW.
#' @param honorificPrefix (Text type.) An honorific prefix preceding a Person's name such as Dr/Mrs/Mr.
#' @param homeLocation (Place or ContactPoint type.) A contact location for a person's residence.
#' @param height (QuantitativeValue or Distance or QuantitativeValue or Distance or QuantitativeValue or Distance or QuantitativeValue or Distance type.) The height of the item.
#' @param hasPOS (Place or Place type.) Points-of-Sales operated by the organization or person.
#' @param hasOfferCatalog (OfferCatalog or OfferCatalog or OfferCatalog type.) Indicates an OfferCatalog listing for this Organization, Person, or Service.
#' @param globalLocationNumber (Text or Text or Text type.) The [Global Location Number](http://www.gs1.org/gln) (GLN, sometimes also referred to as International Location Number or ILN) of the respective organization, person, or place. The GLN is a 13-digit number used to identify parties and physical locations.
#' @param givenName (Text type.) Given name. In the U.S., the first name of a Person. This can be used along with familyName instead of the name property.
#' @param gender (Text or GenderType type.) Gender of the person. While http://schema.org/Male and http://schema.org/Female may be used, text strings are also acceptable for people who do not identify as a binary gender.
#' @param funder (Person or Organization or Person or Organization or Person or Organization or Person or Organization type.) A person or organization that supports (sponsors) something through some kind of financial contribution.
#' @param follows (Person type.) The most generic uni-directional social relation.
#' @param faxNumber (Text or Text or Text or Text type.) The fax number.
#' @param familyName (Text type.) Family name. In the U.S., the last name of an Person. This can be used along with givenName instead of the name property.
#' @param email (Text or Text or Text type.) Email address.
#' @param duns (Text or Text type.) The Dun & Bradstreet DUNS number for identifying an organization or business person.
#' @param deathPlace (Place type.) The place where the person died.
#' @param deathDate (Date type.) Date of death.
#' @param contactPoints (ContactPoint or ContactPoint type.) A contact point for a person or organization.
#' @param contactPoint (ContactPoint or ContactPoint type.) A contact point for a person or organization.
#' @param colleagues (Person type.) A colleague of the person.
#' @param colleague (URL or Person type.) A colleague of the person.
#' @param children (Person type.) A child of the person.
#' @param brand (Organization or Brand or Organization or Brand or Organization or Brand or Organization or Brand type.) The brand(s) associated with a product or service, or the brand(s) maintained by an organization or business person.
#' @param birthPlace (Place type.) The place where the person was born.
#' @param birthDate (Date type.) Date of birth.
#' @param awards (Text or Text or Text or Text type.) Awards won by or for this item.
#' @param award (Text or Text or Text or Text or Text type.) An award won by or for this item.
#' @param alumniOf (Organization or EducationalOrganization type.) An organization that the person is an alumni of.
#' @param affiliation (Organization type.) An organization that this person is affiliated with. For example, a school/university, a club, or a team.
#' @param address (Text or PostalAddress or Text or PostalAddress or Text or PostalAddress or Text or PostalAddress or Text or PostalAddress type.) Physical address of the item.
#' @param additionalName (Text type.) An additional name for a Person, can be used for a middle name.
#' @param url (URL type.) URL of the item.
#' @param sameAs (URL type.) URL of a reference Web page that unambiguously indicates the item's identity. E.g. the URL of the item's Wikipedia page, Wikidata entry, or official website.
#' @param potentialAction (Action type.) Indicates a potential Action, which describes an idealized action in which this thing would play an 'object' role.
#' @param name (Text type.) The name of the item.
#' @param mainEntityOfPage (URL or CreativeWork type.) Indicates a page (or other CreativeWork) for which this thing is the main entity being described. See [background notes](/docs/datamodel.html#mainEntityBackground) for details.
#' @param image (URL or ImageObject type.) An image of the item. This can be a [[URL]] or a fully described [[ImageObject]].
#' @param identifier (URL or Text or PropertyValue type.) The identifier property represents any kind of identifier for any kind of [[Thing]], such as ISBNs, GTIN codes, UUIDs etc. Schema.org provides dedicated properties for representing many of these, either as textual strings or as URL (URI) links. See [background notes](/docs/datamodel.html#identifierBg) for more details.
#' @param disambiguatingDescription (Text type.) A sub property of description. A short description of the item used to disambiguate from other, similar items. Information from other properties (in particular, name) may be necessary for the description to be useful for disambiguation.
#' @param description (Text type.) A description of the item.
#' @param alternateName (Text type.) An alias for the item.
#' @param additionalType (URL type.) An additional type for the item, typically used for adding more specific types from external vocabularies in microdata syntax. This is a relationship between something and a class that the thing is in. In RDFa syntax, it is better to use the native RDFa syntax - the 'typeof' attribute - for multiple types. Schema.org tools may have only weaker understanding of extra types, in particular those defined externally.
#'
#' @return a list object corresponding to a schema:Person
#'
#' @export

 Person <- function(id = NULL,
worksFor = NULL,
 workLocation = NULL,
 weight = NULL,
 vatID = NULL,
 telephone = NULL,
 taxID = NULL,
 spouse = NULL,
 sponsor = NULL,
 siblings = NULL,
 sibling = NULL,
 seeks = NULL,
 relatedTo = NULL,
 publishingPrinciples = NULL,
 performerIn = NULL,
 parents = NULL,
 parent = NULL,
 owns = NULL,
 netWorth = NULL,
 nationality = NULL,
 naics = NULL,
 memberOf = NULL,
 makesOffer = NULL,
 knows = NULL,
 jobTitle = NULL,
 isicV4 = NULL,
 honorificSuffix = NULL,
 honorificPrefix = NULL,
 homeLocation = NULL,
 height = NULL,
 hasPOS = NULL,
 hasOfferCatalog = NULL,
 globalLocationNumber = NULL,
 givenName = NULL,
 gender = NULL,
 funder = NULL,
 follows = NULL,
 faxNumber = NULL,
 familyName = NULL,
 email = NULL,
 duns = NULL,
 deathPlace = NULL,
 deathDate = NULL,
 contactPoints = NULL,
 contactPoint = NULL,
 colleagues = NULL,
 colleague = NULL,
 children = NULL,
 brand = NULL,
 birthPlace = NULL,
 birthDate = NULL,
 awards = NULL,
 award = NULL,
 alumniOf = NULL,
 affiliation = NULL,
 address = NULL,
 additionalName = NULL,
 url = NULL,
 sameAs = NULL,
 potentialAction = NULL,
 name = NULL,
 mainEntityOfPage = NULL,
 image = NULL,
 identifier = NULL,
 disambiguatingDescription = NULL,
 description = NULL,
 alternateName = NULL,
 additionalType = NULL){ 
Filter(Negate(is.null),
 list(
type = "Person",
id = id,
worksFor = worksFor,
workLocation = workLocation,
weight = weight,
vatID = vatID,
telephone = telephone,
taxID = taxID,
spouse = spouse,
sponsor = sponsor,
siblings = siblings,
sibling = sibling,
seeks = seeks,
relatedTo = relatedTo,
publishingPrinciples = publishingPrinciples,
performerIn = performerIn,
parents = parents,
parent = parent,
owns = owns,
netWorth = netWorth,
nationality = nationality,
naics = naics,
memberOf = memberOf,
makesOffer = makesOffer,
knows = knows,
jobTitle = jobTitle,
isicV4 = isicV4,
honorificSuffix = honorificSuffix,
honorificPrefix = honorificPrefix,
homeLocation = homeLocation,
height = height,
hasPOS = hasPOS,
hasOfferCatalog = hasOfferCatalog,
globalLocationNumber = globalLocationNumber,
givenName = givenName,
gender = gender,
funder = funder,
follows = follows,
faxNumber = faxNumber,
familyName = familyName,
email = email,
duns = duns,
deathPlace = deathPlace,
deathDate = deathDate,
contactPoints = contactPoints,
contactPoint = contactPoint,
colleagues = colleagues,
colleague = colleague,
children = children,
brand = brand,
birthPlace = birthPlace,
birthDate = birthDate,
awards = awards,
award = award,
alumniOf = alumniOf,
affiliation = affiliation,
address = address,
additionalName = additionalName,
url = url,
sameAs = sameAs,
potentialAction = potentialAction,
name = name,
mainEntityOfPage = mainEntityOfPage,
image = image,
identifier = identifier,
disambiguatingDescription = disambiguatingDescription,
description = description,
alternateName = alternateName,
additionalType = additionalType))}
