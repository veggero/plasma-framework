/*
 *   Copyright (C) 2006 Aaron Seigo <aseigo@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef PLASMA_ENGINE_MANAGER_H
#define PLASMA_ENGINE_MANAGER_H

#include <QHash>
#include "dataengine.h"

namespace Plasma
{

class PLASMA_EXPORT DataEngineManager
{
    public:
        typedef QHash<QString, Plasma::DataEngine*> Dict;

    public:
        DataEngineManager();
        ~DataEngineManager();

        Plasma::DataEngine* dataEngine(const QString& name) const;
        Plasma::DataEngine* loadDataEngine(const QString& name);
        void unloadDataEngine(const QString& name);

        QStringList knownEngines() const;

    private:
        Plasma::DataEngine::Dict m_engines;
};

} // namespace Plasma

#endif // multiple inclusion guard
