/*
    SPDX-FileCopyrightText: 2014 Ivan Cukic <ivan.cukic(at)kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "icondialog.h"

#include "utils/d_ptr_implementation.h"

#include <QDebug>

#include <KIconDialog>
#include <KWindowSystem>

#include "utils/sharedsingleton.h"

/**
 *
 */
class IconDialog::Private
{
public:
    utils::SharedSingleton<KIconDialog> dialog;
};

IconDialog::IconDialog(QObject *parent)
    : QObject(parent)
{
}

QString IconDialog::openDialog()
{
    auto dialog = d->dialog.instance();

    dialog->setup(KIconLoader::Desktop);
    dialog->setProperty("DoNotCloseController", true);

    KWindowSystem::setOnAllDesktops(dialog->winId(), true);

    dialog->showDialog();
    KWindowSystem::forceActiveWindow(dialog->winId());

    return dialog->openDialog();
}

void IconDialog::closeDialog()
{
    if (d->dialog) {
        auto dialog = d->dialog.instance();
        dialog->close();
    }
}

IconDialog::~IconDialog()
{
}
