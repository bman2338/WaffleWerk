﻿using System;
using System.Web.Profile;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_Users_by_role : System.Web.UI.Page
{

#region Gridview Users

    // on page init get membership roles and bind it to the dropdown menu
    private void Page_Init()
    {
        if (!Page.IsPostBack)
        {
            UserRoles.DataSource = Roles.GetAllRoles();
            UserRoles.DataBind();
        }
    }

    // on page prerender
    private void Page_PreRender()
    {
        BindUserAccounts();
    }

    // hide delete button if gridview returns nothing
    protected void Page_PreRenderComplete(object sender, EventArgs e)
    {
        btnDeleteSelected.Visible = UsersGridView.Rows.Count > 0;
    }

    // create datasource for user gridview
    private void BindUserAccounts()
    {
        int totalRecords;
        MembershipUserCollection allUsers = Membership.GetAllUsers(this.PageIndex, this.PageSize, out totalRecords);
        MembershipUserCollection filteredUsers = new MembershipUserCollection();

        if (UserRoles.SelectedIndex > 0)
        {
            string[] usersInRole = Roles.GetUsersInRole(UserRoles.SelectedValue);
            foreach (MembershipUser user in allUsers)
            {
                foreach (string userInRole in usersInRole)
                {
                    if (userInRole == user.UserName)
                    {
                        filteredUsers.Add(user);

                        // Break out of the inner foreach loop to avoid unneeded checking.
                        break;
                    }
                }
            }
        }
        else
        {
            filteredUsers = allUsers;
        }

        // Enable/disable the pager buttons based on which page we're on
        bool visitingFirstPage = (this.PageIndex == 0);
        lnkFirst.Enabled = !visitingFirstPage;
        lnkPrev.Enabled = !visitingFirstPage;

        int lastPageIndex = (totalRecords - 1) / this.PageSize;
        bool visitingLastPage = (this.PageIndex >= lastPageIndex);
        lnkNext.Enabled = !visitingLastPage;
        lnkLast.Enabled = !visitingLastPage;

        UsersGridView.DataSource = filteredUsers;
        UsersGridView.DataBind();
    }

#endregion

#region Paging Interface Click Event Handlers

    // first pager link
    protected void lnkFirst_Click(object sender, EventArgs e)
    {
        this.PageIndex = 0;
        BindUserAccounts();
    }

    // previous pager link
    protected void lnkPrev_Click(object sender, EventArgs e)
    {
        this.PageIndex -= 1;
        BindUserAccounts();
    }

    // next pager link
    protected void lnkNext_Click(object sender, EventArgs e)
    {
        this.PageIndex += 1;
        BindUserAccounts();
    }

    // last pager link
    protected void lnkLast_Click(object sender, EventArgs e)
    {
        // Determine the total number of records
        int totalRecords;
        Membership.GetAllUsers(this.PageIndex, this.PageSize, out totalRecords);

        // Navigate to the last page index
        this.PageIndex = (totalRecords - 1) / this.PageSize;
        BindUserAccounts();
    }

#endregion

#region Properties for paging

    // put the page index into viewstate
    private int PageIndex
    {
        get
        {
            object o = ViewState["PageIndex"];
            if (o == null)
                return 0;
            else
                return (int)o;
        }
        set
        {
            ViewState["PageIndex"] = value;
        }
    }

    // set the page size for the gridview
    private int PageSize
    {
        get
        {
            return 10;
        }
    }

#endregion

#region Delete one user with trashbin image

    // before the row is deleted
    protected void UserAccounts_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        string userName = UsersGridView.DataKeys[e.RowIndex].Value.ToString();
        ProfileManager.DeleteProfile(userName);
        Membership.DeleteUser(userName);

        //Response.Redirect("default.aspx");
        lblDeleteSuccess.Visible = true;
    }

    // when the rows are being rendered alert user with delete confirmation
    protected void UserAccounts_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ImageButton btn = e.Row.Cells[10].Controls[0] as ImageButton;
            btn.OnClientClick = "if (confirm('Are you sure you want to delete this user?') == false) return false;";
        }
    }

#endregion

#region Delete users selected by checkboxes

    protected void btnDeleteSelected_Click(object sender, EventArgs e)
    {
        foreach (GridViewRow row in UsersGridView.Rows)
        {
            CheckBox cb = (CheckBox)row.FindControl("chkRows");
            if (cb != null && cb.Checked)
            {
                string userName = UsersGridView.DataKeys[row.RowIndex].Value.ToString();
                ProfileManager.DeleteProfile(userName);
                Membership.DeleteUser(userName);

                //Response.Redirect("default.aspx");
                lblDeleteSuccess.Visible = true;
            }
        }
    }

#endregion

}