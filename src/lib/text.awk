@namespace "text"

function headAbout500(content    , splitted, i, description) {
    split(content, splitted, " ")

    for(i in splitted) {
      if (length(description) > 500) {
        break
      }
      description = description " " splitted[i]
    }
    return description
}
