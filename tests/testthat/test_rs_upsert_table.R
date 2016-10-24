context("rs_upsert_table()")

zapieR::make_db_connections()
DBI::dbGetQuery(conn = rs$con, statement = "drop table if exists mtcars_with_id;")
mtcars_with_id <- cbind(id = 1:nrow(mtcars), mtcars)
rs_create_table(.data = mtcars_with_id,
                dbcon = rs$con, table_name = "mtcars_with_id")

test_that(
  "When the table exists but is empty, rs_upsert_table works", {
    uploaded_mtcars <- function() { DBI::dbGetQuery(rs$con, "select * from mtcars_with_id") }
    expect_equal(0, nrow(uploaded_mtcars()))
    expect_true(suppressMessages({
      rs_upsert_table(mtcars_with_id, rs$con, "mtcars_with_id", keys = "id") }
    ))
    expect_equal(dim(uploaded_mtcars()), dim(mtcars_with_id))
    DBI::dbGetQuery(rs$con, "delete from mtcars_with_id where mpg > 20")
    expect_equal(dim(uploaded_mtcars()), dim(mtcars_with_id[!mtcars_with_id$mpg > 20, ]))
    expect_true(suppressMessages({
      rs_upsert_table(mtcars_with_id, rs$con, "mtcars_with_id",
                      key = "id")
    }))

    expect_equal(dim(uploaded_mtcars()), dim(mtcars_with_id))
  }
)

DBI::dbGetQuery(conn = rs$con, statement = "drop table if exists mtcars_with_id;")
