# install.packages('dplyr')
# install.packages('RCurl')
# install.packages('rvest')

library(dplyr)
library(RCurl)
library(rvest)

# 宣言
dir.default <- getwd()

url.top <- 'http://example.net/'
url.search <- 'example.net/dummy'
url.replace.1 <- 'example.net/dummy/img/'
url.replace.2 <- 'example.net/src/img/'
url.posts <- paste('page-', 1:1000000, sep='')

i <- 0

# page
sapply(url.posts, function(url.post) {
  i <<- i + 1
  cat(i, '\t / \t', length(url.posts), '\t: ', url.post, '\t: ')

  tryCatch({
    cat('\t')
    html.post <- read_html(paste(url.top, url.post, sep=''), encoding='UTF-8')
    html.post.title <- html.post %>% html_nodes(xpath='//title') %>% html_text()
    write(paste(url.post, '\t', url.post, '\t', html.post.title, '\t\t', sep=''), 'list.txt', append = T)
    html.post.links <- html.post %>% html_nodes(xpath='//div/a[@target="_blank"]') %>% html_attr('href')
    html.post.links <- html.post.links[grep(url.search, html.post.links)]
    url.post.imgs <- sub(url.replace.1, url.replace.2, html.post.links)
    df <- data.frame(FILE=basename(url.post.imgs), IMG=url.post.imgs, LINK=html.post.links)

    if(nrow(df)>0) {
      cat(length(url.post.imgs), '\t: ')

      dir.create(sub('[?]', '', url.post))
      setwd(paste('./', sub('[?]', '', url.post), sep=''))

      # an image
      apply(df, 1, function(img) {
        tryCatch({
          cat('.')
          writeBin(getBinaryURL(img['IMG'], referer = img['LINK']), img['FILE'])
        },
        warning = {},
        error = {},
        silent = TRUE)
      })
    }

    html.post <- NULL
  },
  warning = function(w) {cat('w')},
  error = function(e) {cat('e')},
  finally = {
    setwd(dir.default)

    cat('\n')
  },
  silent = TRUE)
})


