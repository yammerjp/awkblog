@load "json"
@namespace "controller"

function well_known_webfinger_get(    result, path, resource, accountName, accountId) {
    resource = http::getParameter("resource")
    if (resource !~ /^acct:[a-zA-Z0-9_]+@awkblog.net$/) {
        http::send(404)
    }
    accountName = substr(resource, 6, length(resource) - 17)
    logger::debug(accountName, "activity_pub")
    accountId = model::getAccountId(accountName)
    if (accountId == "") {
        http::send(404)
    }

    result["subject"] = sprintf("acct:%s@awkblog.net", accountName)
    result["links"]["rel"] = "self"
    result["links"]["type"] = "application/activity+json"
    result["links"]["href"] = sprintf("%s/@%s/actor.json", http::getHostName(), accountName)

    httpjson::render(result)
}
