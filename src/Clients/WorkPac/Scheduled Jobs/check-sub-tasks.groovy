// ********************************
// This python script keeps checks for parents that dont have sub-tasks completed.
//
// Created By: Mike Burns
// Last Updated By: Mike Burns
//*********************************

// ********************************
// *** IMPLEMENTATION NOTE ***
// save the following as a script runner filter
// issuetype in subTaskIssueTypes() and statuscategory != "Done" and issueFunction in subtasksOf("statuscategory = done and statusCategoryChangedDate > -1d and statusCategoryChangedDate < -2d")
// then use the filter
// e.g. filter = "<filter name>"
// Parents of Sub-Tasks Not Completed = issueFunction in parentsOf("filter = 'Sub-Tasks not completed'")
// set escalation to run every night in the middle of the night
// ********************************

logger.trace("Event info: Scheduled Job - Check Sub Tasks")

def query = 'category = "Technology Squad" and filter = "Parents of Sub-Tasks Not Completed"'

def searchReq = Unirest.get("/rest/api/2/search")
        .queryString("jql", query)
        .queryString("fields", "key")
        .asObject(Map)
assert searchReq.status == 200
def searchResult = (Map) searchReq.body

searchResult.issues.each { Map issue ->
    def commentResp = Unirest.post("/rest/api/2/issue/${issue.key}/comment")
            .header('Content-Type', 'application/json')
            .body([
                body: """There are unfinished sub-tasks. Please review."""
            ])
            .asObject(Map)

    assert commentResp.status == 201
}

logger.info("Commented on ${searchResult.issues.size()} issues.")

logger.trace("Event info: Scheduled Job - Check Sub Tasks - Completed")