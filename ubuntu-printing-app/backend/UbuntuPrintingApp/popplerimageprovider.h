/*
 * Copyright 2016 Canonical Ltd.
 *
 * This file is part of ubuntu-printing-app.
 *
 * ubuntu-printing-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * ubuntu-printing-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored-by: Andrew Hayzen <andrew.hayzen@canonical.com>
 */
#ifndef POPPLERIMAGEPROVIDER_H
#define POPPLERIMAGEPROVIDER_H

#include <QtQuick/QQuickImageProvider>

class PopplerImageProvider : public QQuickImageProvider
{
public:
    PopplerImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // POPPLERIMAGEPROVIDER_H
